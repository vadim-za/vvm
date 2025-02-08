const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(comptime command_code: u8) Command.Handler {
    return struct {
        fn actualHandler(vvm: *Vvm) void {
            const index: u2 = command_code & 3;
            vvm.registers.addr = vvm.registers.gp.w[index];
        }
    }.actualHandler;
}

test "Test" {
    const arwr = Command.collection.arwr;
    var vvm: Vvm = undefined;

    for (0..arwr.variant_count) |n| {
        const value: u16 = 0x9110 + @as(u16, @intCast(n));

        vvm.memory[0] = arwr.code(n); // ARWR Wn
        vvm.registers.gp.w[n] = value;
        vvm.registers.addr = 0;
        vvm.registers.pc = 0;
        vvm.step();

        try std.testing.expectEqual(value, vvm.registers.addr);
    }
}
