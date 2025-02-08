const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(vvm: *Vvm) void {
    const xa = vvm.registers.a.dw;
    vvm.registers.a.dw = (xa << 1) + (xa >> 31);
}

test "Test" {
    const rol = Command.collection.rol;

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0] = rol.opcode(); // ROL
    vvm.registers.a.w[0] = 0xFEDC;
    vvm.registers.a.w[1] = 0xBA98;
    vvm.registers.pc = 0;
    vvm.step();

    const result = @as(u32, @truncate((0xBA98FEDC << 1) + 1));
    try std.testing.expectEqual(result, vvm.registers.a.dw);
}
