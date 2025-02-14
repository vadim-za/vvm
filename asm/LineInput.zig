// The LineInput object is copyable, allowing to store and restore
// the parsing position within the current line (used by .REP)

const std = @import("std");
const SourceInput = @import("SourceInput.zig");

source_in: *SourceInput,
c: ?u8,
current_pos_number: usize,

pub fn init(source_in: *SourceInput) @This() {
    var self = @This(){
        .source_in = source_in,
        .c = undefined,
        .current_pos_number = undefined,
    };
    self.reset();
    return self;
}

pub fn reset(self: *@This()) void {
    self.c = self.source_in.c;
    self.current_pos_number = 1;
}

pub fn next(self: *@This()) void {
    self.source_in.next();
    self.current_pos_number += 1;
    self.c = switch (self.source_in.c orelse 0) {
        '\n' => blk: {
            self.source_in.next();
            break :blk null;
        },
        '\r' => blk: {
            self.source_in.next();
            if (self.source_in.c == '\n') // Windows CRLF handling
                self.source_in.next();
            break :blk null;
        },
        else => self.source_in.c,
    };
}

pub fn isAtWhitespaceOrEol(self: @This()) bool {
    return if (self.c) |c|
        (c == 32 or c == 9)
    else
        true;
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
