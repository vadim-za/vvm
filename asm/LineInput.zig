const std = @import("std");
const SourceInput = @import("SourceInput.zig");

source_in: *SourceInput,
c: ?u8,
current_pos_number: usize,

pub fn init(source_in: *SourceInput) @This() {
    return .{
        .source_in = source_in,
        .c = source_in.c,
        .current_pos_number = 1,
    };
}

pub fn next(self: *@This()) void {
    self.source_in.next();
    self.current_pos_number += 1;
    self.c = if (self.source_in.c) |c|
        (if (c == '\n') null else c)
    else
        null;
}

pub fn isAtWhitespace(self: @This()) bool {
    return if (self.c) |c|
        (c == 32 or c == 9)
    else
        false;
}

pub fn isAtAlphabetic(self: @This()) bool {
    return if (self.c) |c|
        std.ascii.isAlphabetic(c)
    else
        false;
}

pub fn isAtDigit(self: @This()) bool {
    return if (self.c) |c|
        std.ascii.isDigit(c)
    else
        false;
}

pub fn isAtAlphanumeric(self: @This()) bool {
    return if (self.c) |c|
        std.ascii.isAlphanumeric(c)
    else
        false;
}

pub fn isAtUpper(self: @This(), upper: u8) bool {
    return if (self.c) |c|
        std.ascii.toUpper(c) == upper
    else
        false;
}
