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

    const code = [_]u8{
        0x7A, 0x01, 0x00, // ARV 0x0001
        0x62, 0x41, // LBV 'A'
        0x55, // OUT
        0x50, 0x5A, 0x55, // ZERO ; ARA ; OUT
    };

    const core = &system.core;
    @memcpy(core.memory[0..code.len], &code);
    core.registers.pc = 0;
    if (!system.run(20))
        std.debug.print("\nLooped\n", .{});
}
