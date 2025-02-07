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
            const index: u4 = command_code & 3;
            vvm.registers.a.w = vvm.registers.gp.w[index];
        }
    }.actualHandler;
}

test "Test" {
    var vvm: Vvm = undefined;

    for (0..descriptor.count) |index| {
        vvm.memory[0] = @intCast(descriptor.base + index); // lwr w0
        vvm.registers.gp.w[index] = 0x1110;
        vvm.registers.a.w = 0;
        vvm.registers.pc = 0;
        vvm.step();

        try std.testing.expectEqual(0x1110, vvm.registers.a.w);
    }
}
