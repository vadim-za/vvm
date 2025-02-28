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
            error.LabelTooLong,
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
        return parser.raiseError(
        pos,
        error.LabelExpected,
        "label expected",
        .{},
    );
    parser.skipWhitespace();

    const pos_after_label = in.current_pos_number;
    if (in.c == ':')
        in.next()
    else
        return parser.raiseError(
            pos_after_label,
            error.ColonExpected,
            "label must be followed by a colon",
            .{},
        );

    if (!parser.labels.finalized)
        try parser.labels.push(.{
            .stored_name = stored_name,
            .line = parser.current_line_number,
            .addr = parser.pc,
        });
}

pub fn tryParseLabelAsValueHere(parser: *Parser) !?u16 {
    const in = &parser.line_in;
    const pos = in.current_pos_number;

    const stored_name = (try tryParseLabelNameHere(parser)) orelse return null;

    if (parser.labels.finalized) {
        if (parser.labels.find(stored_name)) |label|
            return @truncate(label.addr)
        else
            return parser.raiseError(
                pos,
                error.UnknownLabel,
                "unknown label '{s}'",
                .{Label.storedNameAsSlice(&stored_name)},
            );
    } else return 0; // return dummy value
}

test "Test" {
    const SourceInput = @import("../SourceInput.zig");

    var in = SourceInput.init("ijk:");
    var parser: Parser = .init(std.testing.allocator, &in, null);
    defer parser.deinit();
    try parseLabelDefinitionHere(&parser);

    const labels = parser.labels.table.items;
    try std.testing.expectEqual(1, labels.len);
    try std.testing.expectEqualStrings("ijk", labels[0].name());
}

test "Test Multiple" {
    const SourceInput = @import("../SourceInput.zig");

    var in = SourceInput.init("ijk:abcdefgh:d:");
    var parser: Parser = .init(std.testing.allocator, &in, null);
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
    try std.testing.expect(items[0].isLessThan(items[1]));
    try std.testing.expect(items[1].isLessThan(items[2]));

    const sn = Label.initStoredName;
    for (&[_][]const u8{ "abcdefgh", "d", "ijk" }) |name| {
        const label = labels.find(sn(name));
        try std.testing.expect(std.mem.order(
            u8,
            name,
            label.?.name(),
        ) == .eq);
    }
    try std.testing.expectEqual(null, labels.find(sn("")));
    try std.testing.expectEqual(null, labels.find(sn("d1")));
    try std.testing.expectEqual(null, labels.find(sn("ij")));
}

test "Parse Label as Value" {
    const SourceInput = @import("../SourceInput.zig");

    var in = SourceInput.init("abc");
    var parser: Parser = .init(std.testing.allocator, &in, null);
    defer parser.deinit();

    try parser.labels.push(.{
        .stored_name = Label.initStoredName("abc"),
        .line = 1,
        .addr = 1000,
    });
    try parser.labels.finalize(&parser);

    const value = try tryParseLabelAsValueHere(&parser);
    try std.testing.expectEqual(1000, value);
}

test "Label Address" {
    const SourceInput = @import("../SourceInput.zig");

    var in = SourceInput.init("abc:");
    var parser: Parser = .init(std.testing.allocator, &in, null);
    defer parser.deinit();

    parser.pc = 1000; // override current value
    try parseLabelDefinitionHere(&parser);
    try parser.labels.finalize(&parser);

    const sn = Label.initStoredName;
    try std.testing.expectEqual(
        1000,
        parser.labels.find(sn("abc")).?.addr,
    );
}
