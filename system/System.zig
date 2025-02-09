const std = @import("std");
const VvmCore = @import("VvmCore");
const Environment = @import("Environment.zig");

core: VvmCore,
env: Environment,

pub fn init(self: *@This()) void {
    self.env.init(self);
    self.core.init();
    self.core.ienv = .init(Environment, &self.env);
}

fn run(self: *@This(), max_steps: ?usize) bool {
    self.env.running = true;

    var remaining_steps = max_steps;
    while (true) {
        if (!self.env.running)
            return true; // successfully finished

        if (remaining_steps) |*steps| {
            if (steps.* == 0)
                return false; // seems to loop indefinitely
            steps.* -|= 1;
        }

        self.core.step();
    }
}

test "Test" {
    var system: @This() = undefined;
    system.init();

    const core = &system.core;
    core.memory[0] = 0x50; // ZERO
    core.memory[1] = 0x5A; // ARA
    core.memory[2] = 0x55; // OUT
    core.registers.pc = 0;
    try std.testing.expect(system.run(10));
    try std.testing.expectEqual(3, core.registers.pc);
}

pub fn main() void {
    var system: @This() = undefined;
    system.init();

    // const code = [_]u8{
    //     0x7A, 0x01, 0x00, // ARV 0x0001
    //     0x62, 0x41, // LBV 'A'
    //     0x55, // OUT
    //     0x50, 0x5A, 0x55, // ZERO ; ARA ; OUT
    // };

    // Intel 8080 code for comparison
    // 0000:    LXI H,0x1000
    // 0003:    MOV A,M
    // 0004:    ORA A
    // 0005:    JZ 0x000E
    // 0008:    OUT 0x01
    // 000A:    INX H
    // 000B:    JMP
    // 000E:
    // 14 vs 24 bytes (70% more)

    const code = [_]u8{
        0x6A, 0x01, 0x00, // 0x00: LWV 0x0001
        0x18, // 0x03: STWR W0 ; W0 == 0x0001
        0x6A, 0x00, 0x10, // 0x04: LWV 0x1000 ; A = running ptr
        // ----------- loop start
        0x19, // 0x07: STWR W1 ; W1 = running_ptr
        0x5A, // 0x08: ARA
        0x60, // 0x09: LBI
        0x7A, 0x18, 0x00, // 0x0A: ARV 0x0018
        0x30, // 0x0D: JIFLZ
        0x48, // 0x0E: ARWR W0 ; ADDR = 0x0001
        0x55, // 0x0F: OUT
        0x09, // 0x10: LWR W1 ; A = running_ptr
        0x7D, // 0x11: CXWX ; X = running_ptr
        0x08, // 0x12: LWR W0 ; A = 1
        0x40, // 0x13: ADD ; A = ++running ptr
        0x7A, 0x07, 0x00, // 0x14: ARV 0x0007
        0x45, // 0x17: JMP
        0x50, 0x5A, 0x55, // 0x18: ZERO, ARA, OUT
    };

    const data = "String\x00";

    const core = &system.core;
    @memcpy(core.memory[0..code.len], &code);
    @memcpy(core.memory[0x1000..][0..data.len], data);
    core.registers.pc = 0;
    if (!system.run(1000))
        std.debug.print("\nLooped\n", .{});
}
