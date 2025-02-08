const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(vvm: *Vvm) void {
    vvm.registers.a.dw = @as(u32, vvm.registers.a.w[0]) + @as(u32, vvm.registers.a.w[1]);
}

test "Test" {
    const add = Command.collection.add;
    var vvm: Vvm = undefined;

    vvm.memory[0] = add.code(0); // ADD
    vvm.registers.a.w[0] = 0x9110;
    vvm.registers.a.w[1] = 0x8000;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x1110, vvm.registers.a.w[0]);
    try std.testing.expectEqual(0x1, vvm.registers.a.w[1]);
}
