const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(vvm: *Vvm) void {
    vvm.registers.a.w[0] = vvm.readMemoryWord(vvm.registers.addr);
}

test "Test" {
    const lwi = Command.collection.lwi;

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0] = lwi.opcode(); // LBI
    vvm.memory[0x1002] = 0x34;
    vvm.memory[0x1003] = 0x12;
    vvm.registers.a.dw = 0;
    vvm.registers.addr = 0x1002;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x1234, vvm.registers.a.w[0]);
}
