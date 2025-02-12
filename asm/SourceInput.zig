const std = @import("std");

source: []const u8,
c: ?u8, // current char, publicly readable, null on EOF
pos: usize,

pub fn init(source: []const u8) @This() {
    var self = @This(){
        .source = source,
        .c = undefined,
        .pos = undefined,
    };
    self.reset();
    return self;
}

pub fn reset(self: *@This()) void {
    self.pos = 0;
    self.fetch();
}

fn fetch(self: *@This()) void {
    self.c = if (self.pos < self.source.len)
        self.source[self.pos]
    else
        null;
}

pub fn next(self: *@This()) void {
    if (self.pos >= self.source.len)
        @panic("Read past EOF");

    self.pos += 1;
    self.fetch();
}
