const std = @import("std");
const Parser = @import("../Parser.zig");
const PassOutput = @import("../PassOutput.zig");

pub fn tryParseStringAsValueHere(parser: *Parser, T: type) !?T {
    const in = &parser.line_in;
    const pos = in.current_pos_number;

    if (in.c == '\'')
        in.next()
    else
        return null;

    var value: T = 0;
    var len: usize = 0;

    while (in.c != '\'') {
        if (in.c) |c| {
            if (len >= @sizeOf(T))
                return parser.raiseError(
                    pos,
                    "A string here cannot be longer than {d} characters",
                    .{@sizeOf(T)},
                );

            value = (value << 8) + c;
            len = len + 1;
        } else return parser.raiseError(
            pos,
            "Unterminated string literal",
            .{},
        );

        in.next();
    }

    in.next(); // consume the apostrophe

    return value;
}

pub fn translateStringHere(parser: *Parser, out: PassOutput) !void {
    const in = &parser.line_in;
    const pos = in.current_pos_number;

    if (in.c == '\'')
        in.next()
    else
        return parser.raiseError(pos, "String literal expected", .{});

    while (in.c != '\'') {
        if (in.c) |c| {
            out.writeByte(c);
        } else return parser.raiseError(
            pos,
            "Unterminated string literal",
            .{},
        );

        in.next();
    }
}
