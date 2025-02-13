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

    if (total_number > 10)
        @compileError(
            "The implementation currently doesn't support register files larger than 10",
        );

    if (!in.isAtDigit())
        return parser.raiseError(pos, "digit expected", .{});

    const n: u8 = in.c.? - '0';
    in.next();

    if (n >= total_number)
        return parser.raiseError(
            pos,
            "{s} register index must be between 0 and {}",
            .{ kind, total_number },
        );

    return @intCast(n);
}

test "Test" {
    const SourceInput = @import("../SourceInput.zig");

    for (0..10) |register_index| {
        inline for ([_][]const u8{ "R{d}", "r{d}" }) |fmt| {
            var source_buffer: [100]u8 = undefined;
            const source =
                try std.fmt.bufPrint(
                &source_buffer,
                fmt,
                .{register_index},
            );
            var in = SourceInput.init(source);
            var parser: Parser = .init(std.testing.allocator, &in);
            defer parser.deinit();
            const parsed_index = try parseRegisterName(
                &parser,
                'R',
                "kind",
                10,
            );
            try std.testing.expectEqual(register_index, parsed_index);
        }
    }
}
