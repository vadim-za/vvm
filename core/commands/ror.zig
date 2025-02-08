const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(vvm: *Vvm) void {
    const xa = vvm.registers.a.dw;
    vvm.registers.a.dw = (xa >> 1) + (xa << 31);
}

test "Test" {
    const ror = Command.collection.ror;

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0] = ror.code(); // ROR
    vvm.registers.a.w[0] = 0xFED9;
    vvm.registers.a.w[1] = 0xBA98;
    vvm.registers.pc = 0;
    vvm.step();

    const result = @as(u32, @truncate((0xBA98FED9 >> 1) + 0x8000_0000));
    try std.testing.expectEqual(result, vvm.registers.a.dw);
}
