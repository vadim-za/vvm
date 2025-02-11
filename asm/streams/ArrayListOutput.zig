const std = @import("std");

data: std.ArrayList(u8),

pub fn init(alloc: std.mem.Allocator) @This() {
    return .{
        .data = .init(alloc),
    };
}

pub fn deinit(self: @This()) void {
    self.data.deinit();
}

pub fn writeByte(self: *@This(), byte: u8) !void {
    return self.data.append(byte);
}
