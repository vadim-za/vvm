const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(comptime command_code: u8) Command.Handler {
    return struct {
        fn actualHandler(vvm: *Vvm) void {
            const index: u3 = command_code & 7;
            vvm.registers.a.b[0] = vvm.registers.gp.b[index];
        }
    }.actualHandler;
}

test "Test" {
    const lbr = Command.collection.lbr;

    var vvm: Vvm = undefined;
    vvm.init();

    inline for (0..lbr.variant_count) |n| {
        const value: u8 = 0x10 + @as(u8, @intCast(n));

        vvm.memory[0] = lbr.opcodeVariant(n); // LBR Bn
        vvm.registers.gp.b[n] = value;
        vvm.registers.a.dw = 0;
        vvm.registers.pc = 0;
        vvm.step();

        try std.testing.expectEqual(value, vvm.registers.a.b[0]);
    }
}
