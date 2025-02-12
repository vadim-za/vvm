const std = @import("std");
const VvmCore = @import("VvmCore");
const asm_streams = @import("asm_streams.zig");

const source =
    \\ lbv 0x10
;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();

    var in = asm_streams.Input.init(source);
    var out: asm_streams.Output = .{ .data = .init(alloc) };

    while (in.c) |byte| : (in.next()) {
        try out.writeByte(byte);
    }

    //try out.print("ABCD", .{});
    std.debug.print("{x}\n", .{out.data.items});
    out.deinit();
}
