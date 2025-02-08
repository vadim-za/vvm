const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(vvm: *Vvm) void {
    vvm.registers.a.w[0] = ~vvm.registers.a.w[0];
}

test "Test" {
    const cpl = Command.collection.cpl;
    var vvm: Vvm = undefined;

    vvm.memory[0] = cpl.code(0); // CPL
    vvm.registers.a.w[0] = 0x9110;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x9110 ^ 0xFFFF, vvm.registers.a.w[0]);
}
