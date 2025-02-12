pos: usize = 0,

pub fn writeByte(self: *@This(), byte: u8) !void {
    _ = byte;
    self.pos += 1;
}

pub fn reset(self: *@This()) void {
    self.pos = 0;
}
