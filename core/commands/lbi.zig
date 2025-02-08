const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(vvm: *Vvm) void {
    vvm.registers.a.b[0] = vvm.memory[vvm.registers.addr];
}

test "Test" {
    const lbi = Command.collection.lbi;

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0] = lbi.opcode(); // LBI
    vvm.memory[0x1002] = 0x10;
    vvm.registers.a.dw = 0;
    vvm.registers.addr = 0x1002;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x10, vvm.registers.a.b[0]);
}
