const std = @import("std");
const Vvm = @import("../Vvm.zig");
const commands = @import("../commands.zig");

pub const descriptor = commands.Descriptor.init(0x69);

pub fn handler(vvm: *Vvm) void {
    const lsb = vvm.fetchCommandByte();
    const hsb = vvm.fetchCommandByte();
    const word: u16 = (@as(u16, hsb) << 8) + lsb;
    vvm.registers.a.w = word;
}

test "Test" {
    var vvm: Vvm = undefined;

    vvm.memory[0] = @intCast(descriptor.base); // LWV
    vvm.memory[1] = 0x34;
    vvm.memory[2] = 0x12;
    vvm.registers.a.w = 0;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x1234, vvm.registers.a.w);
    try std.testing.expectEqual(0x3, vvm.registers.pc);
}
