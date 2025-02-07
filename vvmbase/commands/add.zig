const std = @import("std");
const Vvm = @import("../Vvm.zig");
const commands = @import("../commands.zig");

pub const descriptor = commands.Descriptor.init(0x40);

pub fn handler(vvm: *Vvm) void {
    const result: u32 = @as(u32, vvm.registers.a.w) + @as(u32, vvm.registers.x);
    vvm.registers.a.w = @truncate(result);
    vvm.registers.x = @intCast(result >> 16);
}

test "Test" {
    var vvm: Vvm = undefined;

    vvm.memory[0] = @intCast(descriptor.base); // add
    vvm.registers.a.w = 0x9110;
    vvm.registers.x = 0x8000;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x1110, vvm.registers.a.w);
    try std.testing.expectEqual(0x1, vvm.registers.x);
}
