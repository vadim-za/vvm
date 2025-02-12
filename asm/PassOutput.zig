const std = @import("std");
const bid = @import("VvmCore").bid;
const UnderlyingOutput = @import("ArrayListOutput.zig");
const Parser = @import("Parser.zig");

underlying: ?*UnderlyingOutput,
addr: u16,

pub fn init(underlying: ?*UnderlyingOutput) @This() {
    return .{
        .underlying = underlying,
        .addr = 0,
    };
}

pub fn writeByte(self: *@This(), byte: u8, parser: *Parser) !void {
    if (self.underlying) |u|
        try u.data.append(byte);

    self.addr, const overflow = @addWithOverflow(self.addr, 1);
    if (overflow != 0)
        return parser.raiseError("instruction address overflow", .{});
}

pub fn writeWord(self: *@This(), word: u16, parser: *Parser) !void {
    const lob = bid.loHalf(word);
    const hib = bid.hiHalf(word);
    try self.writeByte(lob, parser);
    try self.writeByte(hib, parser);
}
