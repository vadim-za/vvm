const std = @import("std");
const VvmCore = @import("VvmCore");

const source =
    \\ lbv 0x10
;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();

    var result: std.ArrayList(u8) = .init(alloc);
    var in_stream = std.io.fixedBufferStream(source);

    var in = in_stream.reader().any();
    var out = result.writer().any();
    while (true) {
        const byte = in.readByte() catch break;
        try out.writeByte(byte);
    }

    //try out.print("ABCD", .{});
    std.debug.print("{x}\n", .{result.items});
    result.deinit();
}
