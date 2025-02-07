const std = @import("std");
const Vvm = @import("../Vvm.zig");
const commands = @import("../commands.zig");

pub const descriptor = commands.Descriptor.init(0x44);

pub fn handler(vvm: *Vvm) void {
    vvm.registers.a.w ^= vvm.registers.x;
}

test "Test" {
    var vvm: Vvm = undefined;

    vvm.memory[0] = @intCast(descriptor.base); // XOR
    vvm.registers.a.w = 0x9112;
    vvm.registers.x = 0xC00E;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x511C, vvm.registers.a.w);
}
