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
    var out = result.writer().any();
    try out.print("ABCD", .{});
    std.debug.print("{s}\n", .{result.items});
    result.deinit();
}
