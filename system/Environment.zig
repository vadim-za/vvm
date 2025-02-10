const std = @import("std");
const VvmCore = @import("VvmCore");
const System = @import("System.zig");
const Timer = @import("timer.zig").SystemTimer;

system: *System, // manually set by the owning System
cpu_mode: u8 = 0,
output: std.io.AnyWriter,
keyinput_mode: u8 = 0,

timer: Timer,

// System is not fully initialized yet at the time of the call
pub fn init(self: *@This(), system: *System) void {
    self.* = .{
        .system = system,
        .output = std.io.getStdOut().writer().any(),
        .timer = .init(),
    };
}

fn readKey(self: *@This()) u8 {
    const builtin = @import("builtin");

    if (builtin.os.tag == .windows and self.keyinput_mode == 1) {
        const windows = @import("windows.zig");
        return windows.getKeyboardInput(false);
    } else {
        const reader = std.io.getStdIn().reader();
        return reader.readByte() catch 0;
    }
}

// ------------------ "virtual" methods

pub fn envIn(ptr: ?*anyopaque, port: u8) u8 {
    const self: *@This() = @alignCast(@ptrCast(ptr.?));
    return switch (port) {
        2 => self.readKey(),
        else => 0xFF,
    };
}

pub fn envOut(ptr: ?*anyopaque, port: u8, value: u8) void {
    const self: *@This() = @alignCast(@ptrCast(ptr.?));
    switch (port) {
        0 => {
            self.cpu_mode = value;
            if (value == 2)
                self.timer.wait();
        },
        1 => {
            self.output.writeByte(value) catch {};
        },
        2 => {
            self.keyinput_mode = value;
        },
        3 => {
            self.timer.timeout_4ms = value;
        },
        else => {},
    }
}
