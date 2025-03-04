const std = @import("std");
const Vvm = @import("../Vvm.zig");

pub const variant_type = .none;

pub fn handler(vvm: *Vvm, word: u16) void {
    vvm.writeMemory(vvm.registers.addr +% word, vvm.registers.a.b[0]);
}

test "Test" {
    const stbid = Vvm.commands.stbid;

    var vvm: Vvm = undefined;
    vvm.init();
    vvm.rom_addr = 0xF000;

    @memcpy(vvm.memory[0..3], &stbid.opcodeWithLiteral16(0xCFFB)); // STBID disp
    vvm.memory[0xEFFF] = 0;
    vvm.registers.a.b[0] = 0x10;
    vvm.registers.addr = 0x2004;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x10, vvm.memory[0xEFFF]); // written
    try std.testing.expectEqual(0x3, vvm.registers.pc);

    // Try to write into the ROM
    @memcpy(vvm.memory[0..3], &stbid.opcodeWithLiteral16(0xCFFC)); // STBID disp
    vvm.memory[0xF000] = 0;
    vvm.registers.a.b[0] = 0x10;
    vvm.registers.addr = 0x2004;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0, vvm.memory[0xF000]); // not written
    try std.testing.expectEqual(0x3, vvm.registers.pc);
}
