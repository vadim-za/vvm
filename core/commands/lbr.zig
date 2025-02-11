const std = @import("std");
const Vvm = @import("../Vvm.zig");

pub const variant_type = .byte_register;

pub fn handler(comptime variant_index: u8) fn (*Vvm) void {
    return struct {
        fn actualHandler(vvm: *Vvm) void {
            vvm.registers.a.b[0] = vvm.registers.gp.b[variant_index];
        }
    }.actualHandler;
}

test "Test" {
    const lbr = Vvm.commands.lbr;

    var vvm: Vvm = undefined;
    vvm.init();

    inline for (0..lbr.variant_count) |n| {
        const value: u8 = 0x10 + @as(u8, @intCast(n));

        vvm.memory[0] = lbr.opcodeVariant(n); // LBR Bn
        vvm.registers.gp.b[n] = value;
        vvm.registers.a = .initDword(0);
        vvm.registers.pc = 0;
        vvm.step();

        try std.testing.expectEqual(value, vvm.registers.a.b[0]);
    }
}
