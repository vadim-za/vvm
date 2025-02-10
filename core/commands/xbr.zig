const std = @import("std");
const Vvm = @import("../Vvm.zig");

pub const variant_type = .byte_register;

pub fn handler(comptime command_opcode: u8) fn (*Vvm) void {
    return struct {
        fn actualHandler(vvm: *Vvm) void {
            const index: u3 = command_opcode & 7;
            std.mem.swap(u8, &vvm.registers.a.b[0], &vvm.registers.gp.b[index]);
        }
    }.actualHandler;
}

test "Test" {
    const xbr = Vvm.commands.xbr;

    var vvm: Vvm = undefined;
    vvm.init();

    for (0..xbr.variant_count) |n| {
        const value_offs8: u8 = @intCast(n);
        const value_offs16: u16 = value_offs8;

        vvm.memory[0] = xbr.opcodeVariant(n); // XBR Bn
        vvm.registers.gp.b[n] = 0x10 + value_offs8;
        vvm.registers.a.w[0] = .initWord(0xA090 + value_offs16);
        vvm.registers.pc = 0;
        vvm.step();

        try std.testing.expectEqual(
            0xA010 + value_offs16,
            vvm.registers.a.w[0].asWord(),
        );
        try std.testing.expectEqual(
            0x90 + value_offs8,
            vvm.registers.gp.b[n],
        );
    }
}
