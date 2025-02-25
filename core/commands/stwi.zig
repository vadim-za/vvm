const std = @import("std");
const Vvm = @import("../Vvm.zig");

pub const variant_type = .none;

pub fn handler(vvm: *Vvm) void {
    vvm.writeMemoryWord(
        vvm.registers.addr,
        vvm.registers.a.w[0].asWord(),
    );
}

test "Test" {
    const stwi = Vvm.commands.stwi;

    var vvm: Vvm = undefined;
    vvm.init();
    vvm.rom_addr = 0xF000;

    vvm.memory[0] = stwi.opcode(); // STWI
    vvm.memory[0x1002] = 0;
    vvm.memory[0x1003] = 0;
    vvm.registers.a.w[0] = .initWord(0x1234);
    vvm.registers.addr = 0x1002;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x34, vvm.memory[0x1002]); // written
    try std.testing.expectEqual(0x12, vvm.memory[0x1003]); // written

    // Try to write across the ROM boundary
    vvm.memory[0xEFFE] = 0;
    vvm.memory[0xF000] = 0;
    vvm.registers.a.w[0] = .initWord(0x1234);
    vvm.registers.addr = 0xEFFE;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x34, vvm.memory[0xEFFE]); // written
    try std.testing.expectEqual(0, vvm.memory[0xF000]); // not written
}
