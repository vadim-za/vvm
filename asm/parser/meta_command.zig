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
