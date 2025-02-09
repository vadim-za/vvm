const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(comptime command_opcode: u8) Command.Handler {
    return struct {
        fn actualHandler(vvm: *Vvm) void {
            const index: u2 = command_opcode & 3;
            vvm.registers.a.w[0] = vvm.registers.gp.w[index];
        }
    }.actualHandler;
}

test "Test" {
    const lwr = Command.collection.lwr;

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
