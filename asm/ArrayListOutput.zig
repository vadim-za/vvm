const std = @import("std");

data: *std.ArrayList(u8),

pub fn writeByte(self: *@This(), byte: u8) !void {
    return self.data.append(byte);
}
