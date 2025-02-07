const std = @import("std");
const Vvm = @import("../Vvm.zig");
const commands = @import("../commands.zig");

pub const descriptor = commands.Descriptor.initRange(
    0x20,
    8,
);

pub fn handler(comptime command_code: u8) commands.Handler {
    return struct {
        fn actualHandler(vvm: *Vvm) void {
            const index: u4 = command_code & 7;
            std.mem.swap(u8, &vvm.registers.a.b[0], &vvm.registers.gp.b[index]);
        }
    }.actualHandler;
}

test "Test" {
    var vvm: Vvm = undefined;

    for (0..descriptor.count) |n| {
        const value_offs: u8 = @intCast(n);

        vvm.memory[0] = @intCast(descriptor.base + n); // XBR Bn
        vvm.registers.gp.b[n] = 0x10 + value_offs;
        vvm.registers.a.w = 0xA090 + @as(u16, value_offs);
        vvm.registers.pc = 0;
        vvm.step();

        try std.testing.expectEqual(0x10 + value_offs, vvm.registers.a.b[0]);
        try std.testing.expectEqual(0x90 + value_offs, vvm.registers.gp.b[n]);
    }
}
