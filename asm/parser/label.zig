const std = @import("std");
const Parser = @import("../Parser.zig");
const Label = @import("../Label.zig");

fn tryParseLabelNameHere(parser: *Parser) !?Label.StoredName {
    const in = &parser.line_in;
    const pos = in.current_pos_number;

    if (!in.isAtAlphabetic())
        return null;

    var name: std.BoundedArray(u8, Label.max_length) = .{};
    while (in.isAtAlphanumeric()) {
        name.append(in.c.?) catch
            return parser.raiseError(
            pos,
            "label too long (max length = {})",
            .{Label.max_length},
        );
        in.next();
    }

    return Label.initStoredName(name.constSlice());
}

pub fn parseLabelDefinitionHere(parser: *Parser) !void {
    const in = &parser.line_in;
    const pos = in.current_pos_number;

    const stored_name = (try tryParseLabelNameHere(parser)) orelse
        return parser.raiseError(pos, "label expected", .{});
    parser.skipWhitespace();

    const pos_after_label = in.current_pos_number;
    if (in.c == ':')
        in.next()
    else
        return parser.raiseError(
            pos_after_label,
            "label must be followed by a colon",
            .{},
        );

    try parser.labels.push(.{
        .stored_name = stored_name,
        .line = parser.current_line_number,
        .addr = 0,
    });
}

pub fn tryParseLabelAsValueHere(parser: *Parser, T: type) !?T {
    const name = (try tryParseLabelNameHere(parser)) orelse return null;
    _ = name; // autofix
    if (parser.labels.finalized) {
        unreachable; // todo
    }
    return 0;
}

test "Test" {
    const SourceInput = @import("../SourceInput.zig");

    var in = SourceInput.init("ijk:");
    var parser: Parser = .init(std.testing.allocator, &in);
    defer parser.deinit();
    try parseLabelDefinitionHere(&parser);

    const labels = parser.labels.table.items;
    try std.testing.expectEqual(1, labels.len);
    try std.testing.expectEqualStrings("ijk", labels[0].name());
}

test "Test Multiple" {
    const SourceInput = @import("../SourceInput.zig");

    var in = SourceInput.init("ijk:abcdefgh:d:");
    var parser: Parser = .init(std.testing.allocator, &in);
    defer parser.deinit();
    try parseLabelDefinitionHere(&parser);
    try parseLabelDefinitionHere(&parser);
    try parseLabelDefinitionHere(&parser);

    const labels = &parser.labels;
    const items = labels.table.items;
    try std.testing.expectEqual(3, items.len);
    try std.testing.expectEqualStrings("ijk", items[0].name());
    try std.testing.expectEqualStrings("abcdefgh", items[1].name());
    try std.testing.expectEqualStrings("d", items[2].name());

    try parser.labels.finalize(&parser);
    try std.testing.expectEqualStrings("abcdefgh", items[0].name());
    try std.testing.expectEqualStrings("d", items[1].name());
    try std.testing.expectEqualStrings("ijk", items[2].name());

    try std.testing.expectEqual(&items[0], labels.find("abcdefgh"));
    try std.testing.expectEqual(&items[1], labels.find("d"));
    try std.testing.expectEqual(&items[2], labels.find("ijk"));
    try std.testing.expectEqual(null, labels.find(""));
    try std.testing.expectEqual(null, labels.find("d1"));
    try std.testing.expectEqual(null, labels.find("ij"));
}
