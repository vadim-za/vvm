const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(vvm: *Vvm) void {
    vvm.registers.sp = vvm.registers.a.w[0];
}

test "Test" {
    const stsp = Command.collection.stsp;

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0] = stsp.opcode(); // STSP
    vvm.registers.a.w[0] = 0x1231;
    vvm.registers.sp = 0;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x1231, vvm.registers.sp);
}
