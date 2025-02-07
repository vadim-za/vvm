const std = @import("std");
const Vvm = @import("../Vvm.zig");
const commands = @import("../commands.zig");

pub const descriptor = commands.Descriptor.initRange(
    0x00,
    8,
);

pub fn handler(comptime command_code: u8) commands.Handler {
    return struct {
        fn actualHandler(vvm: *Vvm) void {
            const index: u3 = command_code & 7;
            vvm.registers.a.b[0] = vvm.registers.gp.b[index];
        }
    }.actualHandler;
}

test "Test" {
    var vvm: Vvm = undefined;

    for (0..descriptor.count) |n| {
        const value: u8 = 0x10 + @as(u8, @intCast(n));

        vvm.memory[0] = @intCast(descriptor.base + n); // LBR Bn
        vvm.registers.gp.b[n] = value;
        vvm.registers.a.w = 0;
        vvm.registers.pc = 0;
        vvm.step();

        try std.testing.expectEqual(value, vvm.registers.a.b[0]);
    }
}
