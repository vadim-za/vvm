const std = @import("std");
const Vvm = @import("../Vvm.zig");

pub const variant_type = .none;

pub fn handler(vvm: *Vvm) void {
    vvm.registers.a = .initDword(
        @as(u32, vvm.registers.a.w[0].asWord()) +
            @as(u32, vvm.registers.a.w[1].asWord()),
    );
}

test "Test" {
    const add = Vvm.commands.add;

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0] = add.opcode(); // ADD
    vvm.registers.a.w[0] = .initWord(0x9110);
    vvm.registers.a.w[1] = .initWord(0x8000);
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x1110, vvm.registers.a.w[0].asWord());
    try std.testing.expectEqual(0x1, vvm.registers.a.w[1].asWord());
}
