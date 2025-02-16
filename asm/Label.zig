const std = @import("std");

pub const max_length = 8;
pub const StoredName = [max_length]u8;
const ComparableStoredName = if (@sizeOf(StoredName) == 8)
    u64
else
    @compileError("Unsupported size");

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
    // stored_name has trailing zeroes, so we can simply compare the representations

    // Reference code uses std.mem.order, but we can just compare them as
    // ComparableStoredName's instead.
    // return switch (std.mem.order(u8, &lhs.stored_name, &rhs.stored_name)) {
    //     .lt => true,
    //     .gt => false,
    //     .eq => lhs.line < rhs.line,
    // };

    const cmp_lhs: ComparableStoredName = @bitCast(lhs.stored_name);
    const cmp_rhs: ComparableStoredName = @bitCast(rhs.stored_name);
    return cmp_lhs < cmp_rhs;
}

pub fn compare(context: StoredName, item: @This()) std.math.Order {
    // stored_name has trailing zeroes, so we can simply compare the representations

    // Reference code uses std.mem.order, but we can just compare them as
    // ComparableStoredName's instead.
    // return std.mem.order(u8, &context, &item.stored_name);

    const cmp_lhs: ComparableStoredName = @bitCast(context);
    const cmp_rhs: ComparableStoredName = @bitCast(item.stored_name);
    return std.math.order(cmp_lhs, cmp_rhs);
}

pub fn sameNameAs(self: @This(), other: @This()) bool {
    // stored_name has trailing zeroes, so we can simply compare the representations

    // Reference code uses std.mem.order, but we can just compare them as
    // ComparableStoredName's instead.
    // return std.mem.order(u8, &self.stored_name, &other.stored_name) == .eq;

    const cmp_lhs: ComparableStoredName = @bitCast(self.stored_name);
    const cmp_rhs: ComparableStoredName = @bitCast(other.stored_name);
    return cmp_lhs == cmp_rhs;
}

// Use a pointer for 'self', otherwise the returned slice will be a dangling pointer!
pub fn name(self: *const @This()) []const u8 {
    return storedNameAsSlice(&self.stored_name);
}

// Use a pointer for 'stored_name', otherwise the returned slice will be a dangling pointer!
pub fn storedNameAsSlice(stored_name: *const StoredName) []const u8 {
    return std.mem.sliceTo(stored_name, 0);
}
