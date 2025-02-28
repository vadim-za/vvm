const std = @import("std");
const bid = @import("VvmCore").bid;
const UnderlyingOutput = @import("ArrayListOutput.zig");
const Parser = @import("Parser.zig");

underlying: ?*UnderlyingOutput,
addr: u16,
overflow: bool,

pub fn init(underlying: ?*UnderlyingOutput) @This() {
    return .{
        .underlying = underlying,
        .addr = 0,
        .overflow = false,
    };
}

pub fn writeByte(self: *@This(), byte: u8, parser: *Parser) !void {
    if (self.overflow) // attempt to write after wraparound
        return parser.raiseError(
            1,
            error.AddressOverflow,
            "instruction address overflow",
            .{},
        );

    if (self.underlying) |u|
        try u.data.append(byte);

    self.addr, const overflow = @addWithOverflow(self.addr, 1);
    if (overflow != 0)
        self.overflow = true;
}

pub fn writeWord(self: *@This(), word: u16, parser: *Parser) !void {
    const lob = bid.loHalf(word);
    const hib = bid.hiHalf(word);
    try self.writeByte(lob, parser);
    try self.writeByte(hib, parser);
}

test "Test overflow detection" {
    const @"asm" = @import("asm.zig");

    const Test = struct { []const u8, ?Parser.ErrorInfo.InitTuple };
    const tests = [_]Test{
        .{ " .rep ($FFFF) .db 0\n .dw 0", .{ 2, 1, error.AddressOverflow } },
        .{ " .rep ($FFFF) .db 0\n .db 0\n .db 0", .{ 3, 1, error.AddressOverflow } },
    };

    for (&tests) |t| {
        const source = t[0];
        const expected_error = t[1];

        var error_info: ?Parser.ErrorInfo = null;
        const result =
            @"asm".translateSource(
            std.testing.allocator,
            source,
            &error_info,
        );
        defer {
            // Deinit only if not error
            if (result) |container| container.deinit() else |_| {}
        }

        if (expected_error) |exp| {
            try std.testing.expectEqual(error.SyntaxError, result);
            try std.testing.expect(error_info.?.eqTuple(exp));
        } else {
            _ = try result; // fail upon a returned error
        }
    }
}
