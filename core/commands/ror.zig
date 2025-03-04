const std = @import("std");
const Vvm = @import("../Vvm.zig");

pub const variant_type = .none;

pub fn handler(vvm: *Vvm) void {
    const xa = vvm.registers.a.asDword();
    vvm.registers.a = .initDword(
        std.math.rotr(u32, xa, 1),
    );
}

test "Test" {
    const ror = Vvm.commands.ror;

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0] = ror.opcode(); // ROR
    vvm.registers.a.w[0] = .initWord(0xFED9);
    vvm.registers.a.w[1] = .initWord(0xBA98);
    vvm.registers.pc = 0;
    vvm.step();

    const result = @as(u32, @truncate((0xBA98FED9 >> 1) + 0x8000_0000));
    try std.testing.expectEqual(result, vvm.registers.a.asDword());
}
