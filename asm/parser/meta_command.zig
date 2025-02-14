const std = @import("std");
const Parser = @import("../Parser.zig");
const PassOutput = @import("../PassOutput.zig");
const meta_commands = @import("../meta_commands.zig");
const expression_parser = @import("expression.zig");

const ListEntry = meta_commands.ListEntry;

pub const meta_command_list = [_]ListEntry{
    // zig fmt: off
    .{ "DB",  parseDb },
    .{ "DW",  parseDw },
    .{ "ORG", parseOrg },
    // zig fmt: on
};

fn parseDb(parser: *Parser, out: *PassOutput) Parser.Error!void {
    parser.skipWhitespace();

    try out.writeByte(
        try expression_parser.parseConstantExpressionAs(parser, u8),
        parser,
    );
}

fn parseDw(parser: *Parser, out: *PassOutput) Parser.Error!void {
    parser.skipWhitespace();

    try out.writeWord(
        try expression_parser.parseConstantExpressionAs(parser, u16),
        parser,
    );
}

fn parseOrg(parser: *Parser, out: *PassOutput) Parser.Error!void {
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
