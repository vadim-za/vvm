const std = @import("std");
const Vvm = @import("../Vvm.zig");

pub const variant_type = .none;

pub fn handler(vvm: *Vvm) void {
    std.mem.swap(
        Vvm.WordRegister,
        &vvm.registers.a.w[0],
        &vvm.registers.a.w[1],
    );
}

test "Test" {
    const xa = Vvm.commands.xa;

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0] = xa.opcode(); // XA
    vvm.registers.a.w[0] = .initWord(0xFED9);
    vvm.registers.a.w[1] = .initWord(0xBA98);
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0xBA98, vvm.registers.a.w[0].asWord());
    try std.testing.expectEqual(0xFED9, vvm.registers.a.w[1].asWord());
}
