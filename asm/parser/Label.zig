const std = @import("std");

pub const max_length = 8;
pub const StoredName = [max_length]u8;

stored_name: StoredName,
line: usize,
addr: ?u16 = null,

pub fn initStoredName(str: []const u8) StoredName {
    var stored_name: StoredName = undefined;
    @memset(&stored_name, 0);
    @memcpy(stored_name[0..str.len], str);
    return stored_name;
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
    return std.mem.sliceTo(&self.stored_name, 0);
}
