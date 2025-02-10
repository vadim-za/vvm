const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(vvm: *Vvm) void {
    vvm.registers.a = .initDword(
        @as(u32, vvm.registers.a.w[0].asWord()) -%
            @as(u32, vvm.registers.a.w[1].asWord()),
    );
}

test "Test" {
    const sub = Vvm.commands.sub;

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0] = sub.opcode(); // SUB
    vvm.registers.a.w[0] = .initWord(0x9110);
    vvm.registers.a.w[1] = .initWord(0xB000);
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0xE110, vvm.registers.a.w[0].asWord());
    try std.testing.expectEqual(0xFFFF, vvm.registers.a.w[1].asWord());
}
