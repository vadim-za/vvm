const std = @import("std");
const Vvm = @import("../Vvm.zig");
const commands = @import("../commands.zig");

pub const descriptor = commands.Descriptor.initRange(
    0x18,
    4,
);

pub fn handler(comptime command_code: u8) commands.Handler {
    return struct {
        fn actualHandler(vvm: *Vvm) void {
            const index: u2 = command_code & 3;
            vvm.registers.gp.w[index] = vvm.registers.a.w;
        }
    }.actualHandler;
}

test "Test" {
    var vvm: Vvm = undefined;

    for (0..descriptor.count) |n| {
        const value16: u16 = 0x9110 + @as(u16, @intCast(n));

        vvm.memory[0] = @intCast(descriptor.base + n); // STWR Wn
        vvm.registers.gp.w[n] = 0;
        vvm.registers.a.w = value16;
        vvm.registers.pc = 0;
        vvm.step();

        try std.testing.expectEqual(value16, vvm.registers.gp.w[n]);
    }
}
