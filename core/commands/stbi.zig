const std = @import("std");
const Vvm = @import("../Vvm.zig");

pub const variant_type = .none;

pub fn handler(vvm: *Vvm) void {
    vvm.writeMemory(vvm.registers.addr, vvm.registers.a.b[0]);
}

test "Test" {
    const stbi = Vvm.commands.stbi;

    var vvm: Vvm = undefined;
    vvm.init();
    vvm.rom_addr = 0xF000;

    vvm.memory[0] = stbi.opcode(); // STBI
    vvm.memory[0x1002] = 0;
    vvm.registers.a.b[0] = 0x10;
    vvm.registers.addr = 0x1002;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x10, vvm.memory[0x1002]); // written

    // Try to write into the ROM
    vvm.memory[0xF000] = 0;
    vvm.registers.a.b[0] = 0x10;
    vvm.registers.addr = 0xF000;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0, vvm.memory[0xF000]); // not written
}
