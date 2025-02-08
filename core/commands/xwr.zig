const std = @import("std");
const Vvm = @import("../Vvm.zig");
const commands = @import("../commands.zig");

pub const descriptor = commands.Descriptor.initRange(
    0x28,
    4,
);

pub fn handler(comptime command_code: u8) commands.Handler {
    return struct {
        fn actualHandler(vvm: *Vvm) void {
            const index: u2 = command_code & 3;
            std.mem.swap(u16, &vvm.registers.a.w, &vvm.registers.gp.w[index]);
        }
    }.actualHandler;
}

test "Test" {
    var vvm: Vvm = undefined;

    for (0..descriptor.count) |n| {
        const value_offs: u16 = @intCast(n);

        vvm.memory[0] = @intCast(descriptor.base + n); // LWR Wn
        vvm.registers.gp.w[n] = 0xC010 + value_offs;
        vvm.registers.a.w = 0xA090 + value_offs;
        vvm.registers.pc = 0;
        vvm.step();

        try std.testing.expectEqual(0xC010 + value_offs, vvm.registers.a.w);
        try std.testing.expectEqual(0xA090 + value_offs, vvm.registers.gp.w[n]);
    }
}
