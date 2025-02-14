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

    const source_file_path = args[1];
    const max_steps = if (args.len >= 3) (std.fmt.parseInt(
        usize,
        args[2],
        10,
    ) catch {
        std.debug.print("Second argument must be an integer", .{});
        return 1;
    }) else null;

    var translation_result: std.ArrayList(u8) = .init(alloc);
    defer translation_result.deinit();
    Asm.translateSourceFile(
        alloc,
        source_file_path,
        &translation_result,
    ) catch return 1;
    const code: []const u8 = translation_result.items;

    //std.debug.print("{any}\n", .{code.items});

    var system: System = undefined;
    system.init();

    const core = &system.core;
    @memcpy(core.memory[0..code.len], code);
    core.registers.pc = 0;
    if (!system.run(max_steps))
        std.debug.print("\nLooped\n", .{});

    return 0;
}

test "Test" {
    // Ensure the other tests are performed
    std.testing.refAllDecls(@This());
}
