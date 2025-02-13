const std = @import("std");
const Parser = @import("../Parser.zig");

pub fn parseRegisterName(
    parser: *Parser,
    comptime prefix_uppercase: u8,
    comptime kind: []const u8,
    comptime total_number: u8,
) !u8 {
    const in = &parser.line_in;
    parser.skipWhitespace();

    {
        const pos = in.current_pos_number;
        switch (in.c orelse 0) {
            prefix_uppercase, std.ascii.toLower(prefix_uppercase) => in.next(),
            else => return parser.raiseError(
                pos,
                "expected {s} register name '{c}n'",
                .{ kind, prefix_uppercase },
            ),
        }
    }

    const pos = in.current_pos_number;

    if (total_number >= 10)
        @compileError(
            "The implementation currently doesn't support register files larger than 10",
        );

    if (in.isAtDigit())
        in.next()
    else
        return parser.raiseError(pos, "digit expected", .{});

    const n: u8 = in.c.? - '0';

    if (n >= total_number)
        return parser.raiseError(
            pos,
            "byte register index must be between 0 and {}",
            .{total_number},
        );

    return @intCast(n);
}
