const std = @import("std");
const Vvm = @import("../Vvm.zig");
const bid = @import("../bid.zig");

pub fn handler(vvm: *Vvm) void {
    const lob = vvm.fetchCommandByte();
    const hib = vvm.fetchCommandByte();
    vvm.registers.addr = bid.combine(hib, lob);
}

test "Test" {
    const arv = Vvm.commands.arv;

    var vvm: Vvm = undefined;
    vvm.init();

    @memcpy(vvm.memory[0..3], &arv.opcodeWithLiteral16(0x1234)); // ARV 0x1234
    vvm.registers.addr = 0;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x1234, vvm.registers.addr);
    try std.testing.expectEqual(0x3, vvm.registers.pc);
}
