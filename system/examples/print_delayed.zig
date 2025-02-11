const std = @import("std");
const System = @import("../System.zig");

pub fn run() void {
    var system: System = undefined;
    system.init();

    const code = [_]u8{
        0x50, // 00: ZERO
        0x7A, 0x03, 0x00, // 01: ARV 0x0003
        0x55, // 04: OUT ; 0->3  set timeout to zero
        0x5A, // 05: ARA
        0x62, 0x02, // 06: LBV 0x02
        0x55, // 08: OUT ; 2->0  reset timer
        0x6A, 0x01, 0x00, // 09: LWV 0x0001
        0x18, // 0C: STWR W0 ; W0 == 0x0001
        0x6A, 0x00, 0x10, // 0D: LWV 0x1000 ; A = running ptr
        // ----------- loop start
        0x19, // 10: STWR W1 ; W1 = running_ptr
        0x5A, // 11: ARA
        0x60, // 12: LBI
        0x7A, 0x2F, 0x00, // 13: ARV 0x002F
        0x30, // 16: JIF LZ
        0x48, // 17: ARWR W0 ; ADDR = 0x0001
        0x55, // 18: OUT
        0x09, // 19: LWR W1 ; A = running_ptr
        0x7D, // 1A: CXWX ; X = running_ptr
        0x08, // 1B: LWR W0 ; A = 1
        0x40, // 1C: ADD ; A = ++running ptr
        0x19, // 1D: STWR W1 ; W1 = running_ptr
        0x62, 0xF0, // 1E: LBV 0xF0 ; ca 1 sec delay
        0x7A, 0x03, 0x00, // 20: ARV 0x0003
        0x55, // 23: OUT
        0x62, 0x02, // 24: LBV 0x02
        0x7A, 0x00, 0x00, // 26: ARV 0x0000
        0x55, // 29: OUT ; 2->0  reset timer
        0x09, // 2A: LWR W1 ; A = running ptr
        0x7A, 0x10, 0x00, // 2B: ARV 0x0010
        0x45, // 2E: JMP
        0x50, 0x5A, 0x55, // 2F: ZERO, ARA, OUT
    };

    const data = "String\x00";

    const core = &system.core;
    @memcpy(core.memory[0..code.len], &code);
    @memcpy(core.memory[0x1000..][0..data.len], data);
    core.registers.pc = 0;
    if (!system.run(1000))
        std.debug.print("\nLooped\n", .{});
}
