const std = @import("std");
const System = @import("../System.zig");

pub fn run() void {
    var system: System = undefined;
    system.init();

    const code = [_]u8{
        0x6A, 0x02, 0x00, // 0x00: LWV 0x0002
        0x1A, // 0x03: STWR W2 ; W2 == 0x0002
        0x5A, // 0x04: ARA ; ADDR = 2
        0x6A, 0x01, 0x00, // 0x05: LWV 0x0001
        0x19, // 0x08: STWR W1 ; A = W1 == 0x0001
        0x72, // 0x09: NOP // 0x55, // 0x09: OUT ; 1 -> port2
        // ----------- loop start
        0x4A, // 0x0A: ARWR W2 ; ADDR = 2
        0x54, // 0x0B: IN ; A <- port2
        0x7A, 0x0A, 0x00, // 0x0C: ARV 0x000A
        0x30, // 0x0F: JIF LZ
        0x49, // 0x10: ARWR W1 ; ADDR = 1
        0x55, // 0x11: OUT ; A -> port1
        0x7A, 0x0A, 0x00, // 0x12: ARV 0x000A
        0x45, // 0x15: JMP
    };

    const core = &system.core;
    @memcpy(core.memory[0..code.len], &code);
    core.registers.pc = 0;
    _ = system.run(null);
}
