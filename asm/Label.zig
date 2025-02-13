const std = @import("std");

pub const max_length = 8;
pub const StoredName = [max_length]u8;

stored_name: StoredName,
line: usize,
addr: u16,

pub fn initStoredName(str: []const u8) StoredName {
    var stored_name: StoredName = undefined;
    @memset(&stored_name, 0);
    @memcpy(stored_name[0..str.len], str);
    return stored_name;
}

pub fn lessThan(context: void, lhs: @This(), rhs: @This()) bool {
    _ = context;
    return switch (std.mem.order(u8, lhs.name(), rhs.name())) {
        .lt => true,
        .gt => false,
        .eq => lhs.line < rhs.line,
    };
}

pub fn compare(context: []const u8, item: @This()) std.math.Order {
    return std.mem.order(u8, context, item.name());
}

pub fn sameNameAs(self: @This(), other: @This()) bool {
    // stored_name has trailing zeroes, so we can simply use std.mem.order
    return std.mem.order(u8, &self.stored_name, &other.stored_name) == .eq;
}

pub fn name(self: @This()) []const u8 {
    return std.mem.sliceTo(&self.stored_name, 0);
}
