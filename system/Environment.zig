const std = @import("std");
const VvmCore = @import("VvmCore");
const System = @import("System.zig");

system: *System, // manually set by the owning System
cpu_mode: u8 = 0,
output: std.io.AnyWriter,
keyinput_mode: u8 = 0,

timeout_4ms: u8 = 0, // in 4ms units
prev_timestamp_ms: i64, // in ms

// System is not fully initialized yet at the time of the call
pub fn init(self: *@This(), system: *System) void {
    self.* = .{
        .system = system,
        .output = std.io.getStdOut().writer().any(),
        .prev_timestamp_ms = std.time.milliTimestamp(),
    };
}

// ------------------ "virtual" methods

pub fn envIn(ptr: ?*anyopaque, port: u8) u8 {
    const self: *@This() = @alignCast(@ptrCast(ptr.?));
    return switch (port) {
        2 => {
            const builtin = @import("builtin");
            if (builtin.os.tag == .windows and self.keyinput_mode == 1) {
                const windows = @import("windows.zig");
                return windows.getKeyboardInput(false);
            } else {
                const reader = std.io.getStdIn().reader();
                return reader.readByte() catch 0;
            }
        },
        else => 0xFF,
    };
}

pub fn envOut(ptr: ?*anyopaque, port: u8, value: u8) void {
    const self: *@This() = @alignCast(@ptrCast(ptr.?));
    switch (port) {
        0 => {
            self.cpu_mode = value;
            if (value == 2) {
                const time_ms = std.time.milliTimestamp();
                const elapsed_ms = time_ms -% self.prev_timestamp_ms;
                const timeout_ms = @as(i64, self.timeout_4ms) * 4;
                if (0 <= elapsed_ms and elapsed_ms < timeout_ms) {
                    const wait_ms: u64 = @intCast(timeout_ms - elapsed_ms);
                    std.time.sleep(wait_ms * 1_000_000);
                    self.prev_timestamp_ms +%= timeout_ms; // accommodate sleep()'s jitter
                } else {
                    self.prev_timestamp_ms = time_ms; // already overtime, reset
                }
            }
        },
        1 => {
            self.output.writeByte(value) catch {};
        },
        2 => {
            self.keyinput_mode = value;
        },
        3 => {
            self.timeout_4ms = value;
        },
        else => {},
    }
}
