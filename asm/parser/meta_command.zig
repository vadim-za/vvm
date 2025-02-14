const std = @import("std");
const Parser = @import("../Parser.zig");
const PassOutput = @import("../PassOutput.zig");
const meta_commands = @import("../meta_commands.zig");
const expression_parser = @import("expression.zig");
const string_parser = @import("string.zig");

const ListEntry = meta_commands.ListEntry;

pub const meta_command_list = [_]ListEntry{
    // zig fmt: off
    .{ "DB",  translateDb },
    .{ "DW",  translateDw },
    .{ "DS",  translateDs },
    .{ "ORG", translateOrg },
    // zig fmt: on
};

fn translateDb(parser: *Parser, out: *PassOutput) Parser.Error!void {
    parser.skipWhitespace();

    try out.writeByte(
        try expression_parser.parseConstantExpressionAs(parser, u8),
        parser,
    );
}

fn translateDw(parser: *Parser, out: *PassOutput) Parser.Error!void {
    parser.skipWhitespace();

    try out.writeWord(
        try expression_parser.parseConstantExpressionAs(parser, u16),
        parser,
    );
}

fn translateDs(parser: *Parser, out: *PassOutput) Parser.Error!void {
    parser.skipWhitespace();

    try string_parser.translateStringHere(parser,out);
}

fn translateOrg(parser: *Parser, out: *PassOutput) Parser.Error!void {
    parser.pc = try expression_parser.parseConstantExpressionAs(parser, u16);
    _ = out;
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
