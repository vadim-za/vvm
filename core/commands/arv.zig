const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(vvm: *Vvm) void {
    const lsb = vvm.fetchCommandByte();
    const msb = vvm.fetchCommandByte();
    const word: u16 = (@as(u16, msb) << 8) + lsb;
    vvm.registers.addr = word;
}

test "Test" {
    const arv = Command.collection.arv;

    var vvm: Vvm = undefined;
    vvm.init();

    @memcpy(vvm.memory[0..3], &arv.opcodeWithLiteral16(0x1234)); // ARV 0x1234
    vvm.registers.addr = 0;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x1234, vvm.registers.addr);
    try std.testing.expectEqual(0x3, vvm.registers.pc);
}
