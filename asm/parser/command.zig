const std = @import("std");
const Parser = @import("../Parser.zig");
const PassOutput = @import("../PassOutput.zig");
const commands = @import("../commands.zig");

pub fn parseCommandHere(parser: *Parser, out: *PassOutput) !void {
    const in = &parser.line_in;
    const pos = in.current_pos_number;

    const max_name = 8;
    var name_buffer: std.BoundedArray(u8, max_name) = .{};

    if (!in.isAtAlphabetic())
        return parser.raiseError(
            pos,
            "instruction name must begin with a letter",
            .{},
        );

    while (in.isAtAlphabetic()) {
        name_buffer.append(in.c.?) catch
            return parser.raiseError(
            pos,
            "instruction name too long (max length = {})",
            .{max_name},
        );
        in.next();
    }

    if (!in.isAtWhitespaceOrEol())
        return parser.raiseError(pos, "bad instruction name", .{});

    const name = name_buffer.slice();
    _ = std.ascii.upperString(name, name);
    const command = commands.findUppercase(name) orelse
        return parser.raiseError(
        pos,
        "unknown instruction name '{s}'",
        .{name},
    );

    parser.skipWhitespace();
    try command.translate(parser, out);
}
