const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(vvm: *Vvm) void {
    vvm.registers.addr = vvm.registers.a.w[0];
}

test "Test" {
    const ara = Command.collection.ara;

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0] = ara.opcode(); // ARA
    vvm.registers.a.w[0] = 0x9110;
    vvm.registers.addr = 0;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x9110, vvm.registers.addr);
}
