const std = @import("std");
const streams = @import("asm_streams.zig");
const ResultOutput = streams.Output;
const NullOutput = @import("streams/NullOutput.zig");

const Label = struct {
    const max_length = 8;

    id_bytes: [max_length]u8,
    line: usize,
    addr: u16,

    fn lessThan(context: void, lhs: Label, rhs: Label) bool {
        _ = context; // autofix
        return switch (std.mem.order(u8, lhs.id(), rhs.id())) {
            .lt => true,
            .gt => false,
            .eq => lhs.line < rhs.line,
        };
    }

    fn id(self: *@This()) []u8 {
        return std.mem.sliceTo(&self.id_bytes, 0);
    }
};

labels: std.ArrayList(Label),
c: u8,

fn pass1(self: *@This(), input: *Input) void {
    self.c = input.readByte() orelse return;
}

fn readLine(self: *@This(), input: *Input) ?void {
    self.c = input.readByte() orelse return null;
    if (!isNormalWhitespace(self.c))
        readLabel();
    while (self.c != '\n') {
        self.c = input.readByte() orelse break;
    }
}

fn readLabel(self: *@This(), input: *Input) ?void {
    var len: usize = 0;
    var id_bytes: [Label.max_length]u8 = undefined;
    while (std.ascii.isAlphanumeric(self.c)) {
        if(len >= Label.max_length)
            break;
        id_bytes[len] = self.c;
        len += 1;
        self.c = input.readByte() orelse error unexpected EOF;
    }

    _ = input; // autofix
}

fn isNormalWhitespace(c: u8) bool {
    return c == 32 or c == 9;
}
