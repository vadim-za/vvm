const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Handler = @import("../commands.zig").Handler;

pub fn handler(comptime command_code: u8) Handler {
    return struct {
        fn actualHandler(vvm: *Vvm) void {
            const index: u4 = command_code & 3;
            vvm.registers.a.w = vvm.registers.gp.w[index];
        }
    }.actualHandler;
}

test "Test" {
    var vvm: Vvm = undefined;

    for (0..3) |index| {
        vvm.memory[0] = @intCast(0x08 + index); // lwr w0
        vvm.registers.gp.w[index] = 0x1110;
        vvm.registers.a.w = 0;
        vvm.registers.pc = 0;
        vvm.step();

        try std.testing.expectEqual(0x1110, vvm.registers.a.w);
    }
}
