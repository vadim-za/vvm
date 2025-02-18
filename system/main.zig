const std = @import("std");
const @"asm" = @import("asm");
const System = @import("System.zig");

pub fn main() u8 {
    if (false) { // enable to run local example test
        @import("examples/out_string.zig").run();
        return 0;
    }

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();

    const args = std.process.argsAlloc(alloc) catch {
        std.debug.print("Failed to initialize", .{});
        return 1;
    };
    defer std.process.argsFree(alloc, args);

    if (args.len < 3) {
        const msg =
            \\Usage: vvm command file.vvma
            \\The following commands are supported:
            \\    run[=max_steps]
            \\    dump
        ;
        std.debug.print(msg, .{});
        return 1;
    }

    // parseCommand() prints the error, so we just return on error
    const command = parseCommand(args[1]) catch return 1;
    const source_file_path = args[2];

    const translation_result = @"asm".translateSourceFile(
        alloc,
        source_file_path,
    ) catch return 1;
    defer translation_result.deinit();
    const code: []const u8 = translation_result.items;

    switch (command) {
        .run => |params| runCode(code, params.max_steps),
        .dump => dump(std.io.getStdOut().writer(), code) catch {},
        //std.debug.print("{x}\n", .{code}),
    }
    return 0;
}

fn runCode(code: []const u8, max_steps: ?usize) void {
    var system: System = undefined;
    system.init();

    const core = &system.core;
    @memcpy(core.memory[0..code.len], code);
    core.registers.pc = 0;
    if (!system.run(max_steps))
        std.debug.print("\nLooped\n", .{});
}

fn dump(writer: std.fs.File.Writer, memory: []const u8) !void {
    var addr: usize = 0;
    while (addr < memory.len) : (addr += 16) {
        if (addr >= 0x1_0000) {
            try writer.print("Memory chunk size exceeds 64K\n", .{});
            break;
        }

        try writer.print("{X:0>4}: ", .{addr});

        var offset: usize = 0;
        while (offset < 8) : (offset += 1)
            try dumpByteAsHexAt(writer, memory, addr + offset);
        try writer.print(" ", .{});
        while (offset < 16) : (offset += 1)
            try dumpByteAsHexAt(writer, memory, addr + offset);

        try writer.print(" ", .{});
        offset = 0;
        while (offset < 16) : (offset += 1)
            try dumpByteAsCharAt(writer, memory, addr + offset);

        try writer.print("\n", .{});
    }
}

fn dumpByteAsHexAt(writer: std.fs.File.Writer, memory: []const u8, addr: usize) !void {
    if (addr < memory.len)
        try writer.print("{X:0>2} ", .{memory[addr]})
    else
        try writer.print("   ", .{});
}

fn dumpByteAsCharAt(writer: std.fs.File.Writer, memory: []const u8, addr: usize) !void {
    if (addr < memory.len) {
        const c = memory[addr];
        const printable = c < 0x7F and std.ascii.isPrint(c);
        const print_c = if (printable) c else '.';
        try writer.print("{c}", .{print_c});
    } else {
        try writer.print(" ", .{});
    }
}

// ------------------------------------------------------------------------------

const Command = union(enum) {
    run: struct { max_steps: ?usize },
    dump: void,
};

fn parseCommand(arg: []const u8) !Command {
    if (std.mem.startsWith(u8, arg, "run")) {
        return .{ .run = .{
            .max_steps = try parseEqInt(usize, arg[3..]),
        } };
    } else if (std.mem.order(u8, arg, "dump") == .eq) {
        return .dump;
    } else {
        std.debug.print("Unknown command: {s}\n", .{arg});
        return error.UnknownCommand;
    }
}

fn parseEqInt(T: type, str: []const u8) !?T {
    if (std.mem.startsWith(u8, str, "=")) {
        return std.fmt.parseInt(T, str[1..], 10) catch |err| {
            std.debug.print("Bad integer: {s}", .{str[1..]});
            return err;
        };
    }

    return null;
}

test "Test" {
    // Ensure the other tests are performed
    std.testing.refAllDecls(@This());
}
