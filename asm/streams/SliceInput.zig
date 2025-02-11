slice: []const u8,
pos: usize = 0,

pub fn init(slice: []const u8) @This() {
    return .{
        .slice = slice,
    };
}

pub fn readByte(self: *@This()) ?u8 {
    if (self.pos < self.slice.len) {
        const byte = self.slice[self.pos];
        self.pos += 1;
        return byte;
    }

    return null;
}

pub fn reset(self: *@This()) void {
    self.pos = 0;
}
