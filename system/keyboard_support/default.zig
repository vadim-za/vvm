const std = @import("std");

pub fn setInputMode(mode: u4) void {
    _ = mode;
}

pub fn getInputMode() u4 {
    return 0; // doesn't support any extra modes
}

pub fn readKey() u8 {
    const reader = std.io.getStdIn().reader();
    return reader.readByte() catch 0;
}
