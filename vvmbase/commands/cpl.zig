const std = @import("std");
const Vvm = @import("../Vvm.zig");
const commands = @import("../commands.zig");

pub const descriptor = commands.Descriptor.init(0x52);

pub fn handler(vvm: *Vvm) void {
    vvm.registers.a.w = ~vvm.registers.a.w;
}

test "Test" {
    var vvm: Vvm = undefined;

    vvm.memory[0] = @intCast(descriptor.base); // CPL
    vvm.registers.a.w = 0x9110;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x9110 ^ 0xFFFF, vvm.registers.a.w);
}
