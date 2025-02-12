const std = @import("std");

pub const max_length = 8;

id_bytes: [max_length]u8,
line: usize,
addr: ?u16 = null,

pub fn init(id_slice: []const u8, line: usize) @This() {
    var self = @This(){
        .id_bytes = undefined,
        .line = line,
    };
    @memset(&self.id_bytes, 0);
    @memcpy(self.id_bytes[0..id_slice.len], id_slice);
    return self;
}

pub fn lessThan(context: void, lhs: @This(), rhs: @This()) bool {
    _ = context;
    return switch (std.mem.order(u8, lhs.id(), rhs.id())) {
        .lt => true,
        .gt => false,
        .eq => lhs.line < rhs.line,
    };
}

pub fn id(self: *@This()) []u8 {
    return std.mem.sliceTo(&self.id_bytes, 0);
}
