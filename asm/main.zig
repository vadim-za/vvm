const std = @import("std");
const Asm = @import("Asm.zig");

// const source =
//     \\label12: lbv 0x10
// ;

const source = @embedFile("examples/test.vvma");

pub fn main() u8 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();

    var result: std.ArrayList(u8) = .init(alloc);
    defer result.deinit();
    Asm.translateSource(
        alloc,
        source,
        &result,
    ) catch return 1;

    std.debug.print("{any}\n", .{result.items});

    return 0;
}

test "Test" {
    // Ensure the other tests are performed
    std.testing.refAllDecls(@This());
}
