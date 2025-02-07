const std = @import("std");
const Vvm = @import("../Vvm.zig");
const commands = @import("../commands.zig");

pub const descriptor = commands.Descriptor.init(0x5B);

pub fn handler(vvm: *Vvm) void {
    std.mem.swap(u16, &vvm.registers.a.w, &vvm.registers.x);
}

test "Test" {
    var vvm: Vvm = undefined;

    vvm.memory[0] = @intCast(descriptor.base); // XA
    vvm.registers.a.w = 0xFED9;
    vvm.registers.x = 0xBA98;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0xBA98, vvm.registers.a.w);
    try std.testing.expectEqual(0xFED9, vvm.registers.x);
}
