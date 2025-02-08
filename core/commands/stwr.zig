const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(comptime command_code: u8) Command.Handler {
    return struct {
        fn actualHandler(vvm: *Vvm) void {
            const index: u2 = command_code & 3;
            vvm.registers.gp.w[index] = vvm.registers.a.w[0];
        }
    }.actualHandler;
}

test "Test" {
    const stwr = Command.collection.stwr;
    var vvm: Vvm = undefined;

    for (0..stwr.variant_count) |n| {
        const value16: u16 = 0x9110 + @as(u16, @intCast(n));

        vvm.memory[0] = stwr.codeVariant(n); // STWR Wn
        vvm.registers.gp.w[n] = 0;
        vvm.registers.a.w[0] = value16;
        vvm.registers.pc = 0;
        vvm.step();

        try std.testing.expectEqual(value16, vvm.registers.gp.w[n]);
    }
}
