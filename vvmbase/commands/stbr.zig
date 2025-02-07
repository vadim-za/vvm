const std = @import("std");
const Vvm = @import("../Vvm.zig");
const commands = @import("../commands.zig");

pub const descriptor = commands.Descriptor.initRange(
    0x10,
    8,
);

pub fn handler(comptime command_code: u8) commands.Handler {
    return struct {
        fn actualHandler(vvm: *Vvm) void {
            const index: u4 = command_code & 7;
            vvm.registers.gp.b[index] = vvm.registers.a.b[0];
        }
    }.actualHandler;
}

test "Test" {
    var vvm: Vvm = undefined;

    for (0..descriptor.count) |n| {
        const value16: u16 = 0x9110 + @as(u16, @intCast(n));

        vvm.memory[0] = @intCast(descriptor.base + n); // STBR Bn
        vvm.registers.gp.b[n] = 0;
        vvm.registers.a.w = value16;
        vvm.registers.pc = 0;
        vvm.step();

        const value8: u8 = @truncate(value16);
        try std.testing.expectEqual(value8, vvm.registers.gp.b[n]);
    }
}
