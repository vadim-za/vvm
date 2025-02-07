const std = @import("std");
const Vvm = @import("../Vvm.zig");
const commands = @import("../commands.zig");

pub const descriptor = commands.Descriptor.init(0x53);

pub fn handler(vvm: *Vvm) void {
    std.mem.swap(u8, &vvm.registers.a.b[0], &vvm.registers.a.b[1]);
}

test "Test" {
    var vvm: Vvm = undefined;

    vvm.memory[0] = @intCast(descriptor.base); // CPL
    vvm.registers.a.w = 0x9110;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x1091, vvm.registers.a.w);
}
