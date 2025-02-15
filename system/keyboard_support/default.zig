const std = @import("std");

pub fn setInputMode(mode: u8) void {
    _ = mode;
}

pub fn getInputMode() u8 {
    return 0; // doesn't support any extra modes
}

pub fn readKey() u8 {
    const reader = std.io.getStdIn().reader();
    return reader.readByte() catch 0;
}
