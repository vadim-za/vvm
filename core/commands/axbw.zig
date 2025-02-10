const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(vvm: *Vvm) void {
    vvm.registers.a.b[1] = 0xFF;
}

test "Test" {
    const axbw = Vvm.commands.axbw;

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0] = axbw.opcode(); // AXBW
    vvm.registers.a.b[0] = 0x8F;
    vvm.registers.a.b[1] = 0;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0xFF8F, vvm.registers.a.w[0].asWord());
}
