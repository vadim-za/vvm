const std = @import("std");
const Vvm = @import("../Vvm.zig");
const commands = @import("../commands.zig");

pub const descriptor = commands.Descriptor.init(0x58);

pub fn handler(vvm: *Vvm) void {
    const xa: u32 = (@as(u32, vvm.registers.x) << 16) + vvm.registers.a.w;
    const xa_rol = (xa << 1) + (xa >> 31);
    vvm.registers.a.w = @truncate(xa_rol);
    vvm.registers.x = @intCast(xa_rol >> 16);
}

test "Test" {
    var vvm: Vvm = undefined;

    vvm.memory[0] = @intCast(descriptor.base); // ROL
    vvm.registers.a.w = 0xFEDC;
    vvm.registers.x = 0xBA98;
    vvm.registers.pc = 0;
    vvm.step();

    const result = @as(u32, @truncate((0xBA98FEDC << 1) + 1));
    const result_lsw: u16 = @truncate(result);
    const result_hsw: u16 = result >> 16;
    try std.testing.expectEqual(result_lsw, vvm.registers.a.w);
    try std.testing.expectEqual(result_hsw, vvm.registers.x);
}
