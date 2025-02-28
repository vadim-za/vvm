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

test "Overflow detection" {
    const @"asm" = @import("asm.zig");

    const tests = [_]@"asm".TranslateSourceErrorTest{
        .{ " .rep ($FFFF) .db 0\n .dw 0", .{ 2, 1, error.AddressOverflow } },
        .{ " .rep ($FFFF) .db 0\n .db 0\n .db 0", .{ 3, 1, error.AddressOverflow } },
    };

    try @"asm".testTranslateSourceErrors(&tests);
}
