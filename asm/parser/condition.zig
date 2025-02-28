const std = @import("std");
const Parser = @import("../Parser.zig");

// This function always succeeds, since condition register may be empty
fn parseConditionRegisterHere(parser: *Parser) u8 {
    const in = &parser.line_in;

    switch (in.c orelse 0) {
        'H', 'h' => {
            in.next();
            return 1;
        },
        'L', 'l' => {
            in.next();
            return 0;
        },
        'X', 'x' => {
            in.next();
            return 3;
        },
        else => return 2, // accumulator
    }
}

// This is an auxiliary function of parseCondition(), it returns null on error
fn parseConditionNameHere(parser: *Parser) ?u8 {
    const in = &parser.line_in;

    const reg = parseConditionRegisterHere(parser);

    var invert: u1 = 0;
    switch (in.c orelse 0) {
        'N', 'n' => {
            invert = 1;
            in.next();
        },
        else => {},
    }

    switch (in.c orelse 0) {
        'Z', 'z' => in.next(),
        else => return null,
    }

    return invert + reg * 2;
}

pub fn parseCondition(parser: *Parser) !u8 {
    const in = &parser.line_in;
    parser.skipWhitespace();
    const pos = in.current_pos_number;

    if (parseConditionNameHere(parser)) |condition_code|
        return condition_code
    else
        return parser.raiseError(
            pos,
            error.BadCondition,
            "bad condition name",
            .{},
        );
}

test "Test" {
    const SourceInput = @import("../SourceInput.zig");

    const conditions = [_][]const u8{
        "lz", "lnz", "hz", "hnz", "z", "nz", "xz", "xnz",
        "LZ", "LNZ", "HZ", "HNZ", "Z", "NZ", "XZ", "XNZ",
    };
    for (&conditions, 0..) |source, index| {
        var in = SourceInput.init(source);
        var parser: Parser = .init(std.testing.allocator, &in, null);
        defer parser.deinit();
        const parsed_index = try parseCondition(&parser);
        try std.testing.expectEqual(index % 8, parsed_index);
    }
}

test "Bad condition name" {
    const SourceInput = @import("../SourceInput.zig");

    const conditions = [_][]const u8{
        "l", "h", "x", "", "a",
    };
    for (&conditions) |source| {
        var in = SourceInput.init(source);
        var error_info: ?Parser.ErrorInfo = null;

        var parser: Parser = .init(std.testing.allocator, &in, &error_info);
        defer parser.deinit();

        const result = parseCondition(&parser);
        try std.testing.expectEqual(error.SyntaxError, result);
        try std.testing.expect(error_info.?.isAt(1, 1, error.BadCondition));
    }
}
