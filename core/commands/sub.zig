const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(vvm: *Vvm) void {
    vvm.registers.a.dw = @as(u32, vvm.registers.a.w[0]) -% @as(u32, vvm.registers.a.w[1]);
}

test "Test" {
    const sub = Command.collection.sub;
    var vvm: Vvm = undefined;

    vvm.memory[0] = sub.base_code; // SUB
    vvm.registers.a.w[0] = 0x9110;
    vvm.registers.a.w[1] = 0xB000;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0xE110, vvm.registers.a.w[0]);
    try std.testing.expectEqual(0xFFFF, vvm.registers.a.w[1]);
}
