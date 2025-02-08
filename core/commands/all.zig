const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(vvm: *Vvm) void {
    vvm.registers.a.w[0] = 0xFFFF;
}

test "Test" {
    const all = Command.collection.all;
    var vvm: Vvm = undefined;

    vvm.memory[0] = all.code(0); // ALL
    vvm.registers.a.w[0] = 0x9110;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0xFFFF, vvm.registers.a.w[0]);
}
