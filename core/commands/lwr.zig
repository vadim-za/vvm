const std = @import("std");
const Vvm = @import("../Vvm.zig");

pub const variant_type = .word_register;

pub fn handler(comptime variant_index: u8) fn(*Vvm) void {
    return struct {
        fn actualHandler(vvm: *Vvm) void {
            vvm.registers.a.w[0] = vvm.registers.gp.w[variant_index];
        }
    }.actualHandler;
}

test "Test" {
    const lwr = Vvm.commands.lwr;

    var vvm: Vvm = undefined;
    vvm.init();

    for (0..lwr.variant_count) |n| {
        const value: u16 = 0x9110 + @as(u16, @intCast(n));

        vvm.memory[0] = lwr.opcodeVariant(n); // LWR Wn
        vvm.registers.gp.w[n] = .initWord(value);
        vvm.registers.a = .initDword(0);
        vvm.registers.pc = 0;
        vvm.step();

        try std.testing.expectEqual(value, vvm.registers.a.w[0].asWord());
    }
}
