const std = @import("std");
const Asm = @import("Asm");
const System = @import("System.zig");

pub fn main() u8 {
    //@import("examples/out_string.zig").run();

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

    var translation_result: std.ArrayList(u8) = .init(alloc);
    defer translation_result.deinit();
    Asm.translateSourceFile(
        alloc,
        args[1],
        &translation_result,
    ) catch return 1;
    const code: []const u8 = translation_result.items;

    //std.debug.print("{any}\n", .{code.items});

    var system: System = undefined;
    system.init();

    const core = &system.core;
    @memcpy(core.memory[0..code.len], code);
    core.registers.pc = 0;
    if (!system.run(1000))
        std.debug.print("\nLooped\n", .{});

    return 0;
}

test "Test" {
    // Ensure the other tests are performed
    std.testing.refAllDecls(@This());
}
