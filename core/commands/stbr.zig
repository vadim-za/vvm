const std = @import("std");
const Vvm = @import("../Vvm.zig");

pub const variant_type = .byte_register;

pub fn handler(comptime variant_index: u8) fn (*Vvm) void {
    return struct {
        fn actualHandler(vvm: *Vvm) void {
            vvm.registers.gp.b[variant_index] = vvm.registers.a.b[0];
        }
    }.actualHandler;
}

test "Test" {
    const stbr = Vvm.commands.stbr;

    var vvm: Vvm = undefined;
    vvm.init();

    for (0..stbr.variant_count) |n| {
        const value16: u16 = 0x9110 + @as(u16, @intCast(n));

        vvm.memory[0] = stbr.opcodeVariant(n); // STBR Bn
        vvm.registers.gp.b[n] = 0;
        vvm.registers.a.w[0] = .initWord(value16);
        vvm.registers.pc = 0;
        vvm.step();

        const value8: u8 = @truncate(value16);
        try std.testing.expectEqual(value8, vvm.registers.gp.b[n]);
    }
}
