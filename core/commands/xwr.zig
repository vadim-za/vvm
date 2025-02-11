const std = @import("std");
const Vvm = @import("../Vvm.zig");

pub const variant_type = .word_register;

pub fn handler(comptime variant_index: u8) fn(*Vvm) void {
    return struct {
        fn actualHandler(vvm: *Vvm) void {
            std.mem.swap(
                Vvm.WordRegister,
                &vvm.registers.a.w[0],
                &vvm.registers.gp.w[variant_index],
            );
        }
    }.actualHandler;
}

test "Test" {
    const xwr = Vvm.commands.xwr;

    var vvm: Vvm = undefined;
    vvm.init();

    for (0..xwr.variant_count) |n| {
        const value_offs: u16 = @intCast(n);

        vvm.memory[0] = xwr.opcodeVariant(n); // XWR Wn
        vvm.registers.gp.w[n] = .initWord(0xC010 + value_offs);
        vvm.registers.a.w[0] = .initWord(0xA090 + value_offs);
        vvm.registers.pc = 0;
        vvm.step();

        try std.testing.expectEqual(
            0xC010 + value_offs,
            vvm.registers.a.w[0].asWord(),
        );
        try std.testing.expectEqual(
            0xA090 + value_offs,
            vvm.registers.gp.w[n].asWord(),
        );
    }
}
