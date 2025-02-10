const std = @import("std");
const Vvm = @import("../Vvm.zig");

pub fn handler(vvm: *Vvm, word: u16) void {
    vvm.registers.a.w[0] = .initWord(word);
}

test "Test" {
    const lwv = Vvm.commands.lwv;

    var vvm: Vvm = undefined;
    vvm.init();

    @memcpy(vvm.memory[0..3], &lwv.opcodeWithLiteral16(0x1234)); // LWV 0x1234
    vvm.registers.a.w[0] = .initWord(0);
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(
        0x1234,
        vvm.registers.a.w[0].asWord(),
    );
    try std.testing.expectEqual(0x3, vvm.registers.pc);
}
