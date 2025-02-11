const std = @import("std");
const Vvm = @import("../Vvm.zig");

pub const variant_type = .word_register;

pub fn handler(comptime variant_index: u8) fn(*Vvm) void {
    return struct {
        fn actualHandler(vvm: *Vvm) void {
            vvm.registers.gp.w[variant_index] = vvm.registers.a.w[0];
        }
    }.actualHandler;
}

test "Test" {
    const stwr = Vvm.commands.stwr;

    var vvm: Vvm = undefined;
    vvm.init();

    for (0..stwr.variant_count) |n| {
        const value16: u16 = 0x9110 + @as(u16, @intCast(n));

        vvm.memory[0] = stwr.opcodeVariant(n); // STWR Wn
        vvm.registers.gp.w[n] = .initWord(0);
        vvm.registers.a.w[0] = .initWord(value16);
        vvm.registers.pc = 0;
        vvm.step();

        try std.testing.expectEqual(value16, vvm.registers.gp.w[n].asWord());
    }
}
