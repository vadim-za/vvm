const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Handler = @import("../commands.zig").Handler;

pub fn handler(comptime command_code: u8) Handler {
    return struct {
        fn actualHandler(vvm: *Vvm) void {
            const index: u4 = command_code & 7;
            vvm.registers.a.b[0] = vvm.registers.gp.b[index];
        }
    }.actualHandler;
}

test "Test" {
    var vvm: Vvm = undefined;

    for (0..7) |index| {
        vvm.memory[0] = @intCast(0x00 + index); // lbr b0
        vvm.registers.gp.b[index] = 0x10;
        vvm.registers.a.w = 0;
        vvm.registers.pc = 0;
        vvm.step();

        try std.testing.expectEqual(0x10, vvm.registers.a.b[0]);
    }
}
