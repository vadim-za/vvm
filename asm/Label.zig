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
    // stored_name has trailing zeroes, so we can simply use std.mem.order
    return switch (std.mem.order(u8, &lhs.stored_name, &rhs.stored_name)) {
        .lt => true,
        .gt => false,
        .eq => lhs.line < rhs.line,
    };
}

pub fn compare(context: StoredName, item: @This()) std.math.Order {
    // stored_name has trailing zeroes, so we can simply use std.mem.order
    return std.mem.order(u8, &context, &item.stored_name);
}

pub fn sameNameAs(self: @This(), other: @This()) bool {
    // stored_name has trailing zeroes, so we can simply use std.mem.order
    return std.mem.order(u8, &self.stored_name, &other.stored_name) == .eq;
}

// Use a pointer for 'self', otherwise the returned slice will be a dangling pointer!
pub fn name(self: *const @This()) []const u8 {
    return storedNameAsSlice(&self.stored_name);
}

// Use a pointer for 'stored_name', otherwise the returned slice will be a dangling pointer!
pub fn storedNameAsSlice(stored_name: *const StoredName) []const u8 {
    return std.mem.sliceTo(stored_name, 0);
}
