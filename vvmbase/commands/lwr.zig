const std = @import("std");
const Vvm = @import("../Vvm.zig");
const commands = @import("../commands.zig");

pub const descriptor = commands.Descriptor.initRange(
    0x08,
    4,
);

pub fn handler(comptime command_code: u8) commands.Handler {
    return struct {
        fn actualHandler(vvm: *Vvm) void {
            const index: u2 = command_code & 3;
            vvm.registers.a.w = vvm.registers.gp.w[index];
        }
    }.actualHandler;
}

test "Test" {
    var vvm: Vvm = undefined;

    for (0..descriptor.count) |n| {
        const value: u16 = 0x9110 + @as(u16, @intCast(n));

        vvm.memory[0] = @intCast(descriptor.base + n); // LWR Wn
        vvm.registers.gp.w[n] = value;
        vvm.registers.a.w = 0;
        vvm.registers.pc = 0;
        vvm.step();

        try std.testing.expectEqual(value, vvm.registers.a.w);
    }
}
