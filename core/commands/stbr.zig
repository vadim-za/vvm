const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(comptime command_opcode: u8) Command.Handler {
    return struct {
        fn actualHandler(vvm: *Vvm) void {
            const index: u3 = command_opcode & 7;
            vvm.registers.gp.b[index] = vvm.registers.a.b[0];
        }
    }.actualHandler;
}

test "Test" {
    const stbr = Command.collection.stbr;

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
