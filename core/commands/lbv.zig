const std = @import("std");
const Vvm = @import("../Vvm.zig");
const commands = @import("../commands.zig");

pub const descriptor = commands.Descriptor.init(0x61);

pub fn handler(vvm: *Vvm) void {
    const byte = vvm.fetchCommandByte();
    vvm.registers.a.b[0] = byte;
}

test "Test" {
    var vvm: Vvm = undefined;

    vvm.memory[0] = @intCast(descriptor.base); // LBV
    vvm.memory[1] = 0x10;
    vvm.registers.a.w = 0;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x10, vvm.registers.a.b[0]);
    try std.testing.expectEqual(0x2, vvm.registers.pc);
}
