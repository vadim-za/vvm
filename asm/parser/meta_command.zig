const std = @import("std");
const Parser = @import("../Parser.zig");
const PassOutput = @import("../PassOutput.zig");
const meta_commands = @import("../meta_commands.zig");
const expression_parser = @import("expression.zig");
const string_parser = @import("string.zig");

const ListEntry = meta_commands.ListEntry;

pub const meta_command_list = [_]ListEntry{
    // somehow 'zig fmt: on' below stopped working, so leave it on for now
    // // zig fmt: off
    .{ "DB", translateDb },
    .{ "DW", translateDw },
    .{ "DS", translateDs },
    .{ "ORG", translateOrg },
    .{ "REP", translateRep },
    // zig fmt: on
};

fn translateDb(parser: *Parser, out: *PassOutput) Parser.Error!void {
    parser.skipWhitespace();

    parser.pc +%= 1;
    try out.writeByte(
        try expression_parser.parseExpressionAs(
            parser,
            u8,
            true,
        ),
        parser,
    );
}

fn translateDw(parser: *Parser, out: *PassOutput) Parser.Error!void {
    parser.skipWhitespace();

    parser.pc +%= 2;
    try out.writeWord(
        try expression_parser.parseExpressionAs(
            parser,
            u16,
            true,
        ),
        parser,
    );
}

fn translateDs(parser: *Parser, out: *PassOutput) Parser.Error!void {
    parser.skipWhitespace();

    try string_parser.translateStringHere(parser, out);
}

fn translateOrg(parser: *Parser, out: *PassOutput) Parser.Error!void {
    // Don't allow labels, since they are not known during the first pass
    // Currently we also do not allow other expressions.
    parser.pc = try expression_parser.parseExpressionAs(
        parser,
        u16,
        false,
    );
    _ = out;
}

fn translateRep(parser: *Parser, out: *PassOutput) Parser.Error!void {
    // Don't allow labels, since they are not known during the first pass
    // Currently we also do not allow other expressions.
    const num_repetitions =
        try expression_parser.parseParenthesizedExpressionAs(
        parser,
        u16,
        false,
    );

    const in = &parser.line_in;
    const pos = in.current_pos_number;

    if (!in.isAtWhitespace())
        return parser.raiseError(
            pos,
            "whitespace expected",
            .{},
        );
    parser.skipWhitespace();

    // We don't have an option of simply skipping the commands, therefore
    // we cannot support zero repetitions. One can use comment feature instead.
    if (num_repetitions == 0)
        return parser.raiseError(
            pos,
            "number of repetitions must be greater than 0",
            .{},
        );

    const stored_input_state = parser.storeInputState();
    for (0..num_repetitions) |_| {
        parser.restoreInputState(stored_input_state);
        const pos_repeated = in.current_pos_number;

        if (!try tryParseMetaCommandHere(parser, out))
            return parser.raiseError(
                pos_repeated,
                "metacommand expected",
                .{},
            );
    }
}

pub fn tryParseMetaCommandHere(parser: *Parser, out: *PassOutput) !bool {
    const in = &parser.line_in;
    const pos = in.current_pos_number;

    if (in.c == '.')
        in.next()
    else
        return false;

    const max_name = 8;
    var name_buffer: std.BoundedArray(u8, max_name) = .{};

    if (!in.isAtAlphabetic())
        return parser.raiseError(
            pos,
            "metainstruction name must begin with a letter",
            .{},
        );

    while (in.isAtAlphabetic()) {
        name_buffer.append(in.c.?) catch
            return parser.raiseError(
            pos,
            "metainstruction name too long (max length = {})",
            .{max_name},
        );
        in.next();
    }

    if (!in.isAtWhitespaceOrEol())
        return parser.raiseError(pos, "bad metainstruction name", .{});

    const name = name_buffer.slice();
    _ = std.ascii.upperString(name, name);
    const command = meta_commands.findUppercase(name) orelse
        return parser.raiseError(
        pos,
        "unknown metainstruction name '{s}'",
        .{name},
    );

    parser.skipWhitespace();
    try command.translate(parser, out);

    return true;
}

test "Test data write" {
    const @"asm" = @import("../asm.zig");

    const Test = struct { []const u8, []const u8 };
    const tests = [_]Test{
        .{ " .db 1", &[_]u8{1} },
        .{ " .dw $1234", &[_]u8{ 0x34, 0x12 } },
        .{ " .db abc+$ABCD\nabc:", &[_]u8{0xCE} },
        .{ " .dw abc+$ABCD\nabc:", &[_]u8{ 0xCF, 0xAB } },
        .{ " .ds 'ABC'", &[_]u8{ 'A', 'B', 'C' } },
        .{ " .rep (2) .ds 'AB'", &[_]u8{ 'A', 'B', 'A', 'B' } },
    };

    for (&tests) |t| {
        const source = t[0];
        const expected_result = t[1];

        const result_container =
            try @"asm".translateSource(
            std.testing.allocator,
            source,
            null,
        );
        defer result_container.deinit();
        const result = result_container.items;

        try std.testing.expect(std.mem.order(u8, expected_result, result) == .eq);
    }
}

test "Test labels not allowed" {
    const @"asm" = @import("../asm.zig");

    const Test = struct { []const u8, usize };
    const tests = [_]Test{
        .{ "abc:.org abc", 10 },
        .{ "abc:.rep (1+abc) .ds 0", 13 },
    };

    for (&tests) |t| {
        const source = t[0];
        const expected_error_pos = t[1];

        var error_info: Parser.ErrorInfo = undefined;
        const result =
            @"asm".translateSource(
            std.testing.allocator,
            source,
            &error_info,
        );
        try std.testing.expect(result == error.SyntaxError);
        // Since we expect an error, don't need to deinit the result

        try std.testing.expect(error_info.isAt(1, expected_error_pos));
    }
}
