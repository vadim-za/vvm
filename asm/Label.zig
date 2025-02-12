const std = @import("std");

pub const max_length = 8;
pub const Name = [max_length]u8;

name_bytes: Name,
line: usize,
addr: ?u16 = null,

pub fn init(name_: Name, line: usize) @This() {
    return .{
        .name_bytes = name_,
        .line = line,
    };
}

pub fn initName(name_: []const u8) Name {
    var name_bytes: Name = undefined;
    @memset(&name_bytes, 0);
    @memcpy(name_bytes[0..name_.len], name_);
    return name_bytes;
}

pub fn lessThan(context: void, lhs: @This(), rhs: @This()) bool {
    _ = context;
    return switch (std.mem.order(u8, lhs.id(), rhs.id())) {
        .lt => true,
        .gt => false,
        .eq => lhs.line < rhs.line,
    };
}

pub fn name(self: *@This()) []u8 {
    return std.mem.sliceTo(&self.name_bytes, 0);
}
