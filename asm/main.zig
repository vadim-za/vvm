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

    const args = std.process.argsAlloc(alloc) catch {
        std.debug.print("Failed to initialize", .{});
        return 1;
    };
    defer std.process.argsFree(alloc, args);

    if (args.len < 2) {
        std.debug.print("Argument expected\n", .{});
        return 1;
    }

    var result: std.ArrayList(u8) = .init(alloc);
    defer result.deinit();
    // Asm.translateSource(
    //     alloc,
    //     source,
    //     &result,
    // ) catch return 1;
    Asm.translateSourceFile(
        alloc,
        args[1], //"asm/examples/test.vvma",
        &result,
    ) catch return 1;

    std.debug.print("{any}\n", .{result.items});

    return 0;
}

test "Test" {
    // Ensure the other tests are performed
    std.testing.refAllDecls(@This());
}
