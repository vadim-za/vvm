const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(vvm: *Vvm) void {
    vvm.registers.a.w[0] |= vvm.registers.a.w[1];
}

test "Test" {
    const @"or" = Command.collection.@"or";
    var vvm: Vvm = undefined;

    vvm.memory[0] = @"or".code(); // OR
    vvm.registers.a.w[0] = 0x9112;
    vvm.registers.a.w[1] = 0xC00E;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0xD11E, vvm.registers.a.w[0]);
}
