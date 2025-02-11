const std = @import("std");
const Vvm = @import("../Vvm.zig");

pub const variant_type = .word_register;

pub fn handler(comptime variant_index: u8) fn (*Vvm) void {
    return struct {
        fn actualHandler(vvm: *Vvm) void {
            vvm.registers.addr = vvm.registers.gp.w[variant_index].asWord();
        }
    }.actualHandler;
}

test "Test" {
    const arwr = Vvm.commands.arwr;

    var vvm: Vvm = undefined;
    vvm.init();

    for (0..arwr.variant_count) |n| {
        const value: u16 = 0x9110 + @as(u16, @intCast(n));

        vvm.memory[0] = arwr.opcodeVariant(n); // ARWR Wn
        vvm.registers.gp.w[n] = .initWord(value);
        vvm.registers.addr = 0;
        vvm.registers.pc = 0;
        vvm.step();

        try std.testing.expectEqual(value, vvm.registers.addr);
    }
}
