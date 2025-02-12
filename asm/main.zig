const std = @import("std");
const VvmCore = @import("VvmCore");
const SourceInput = @import("SourceInput.zig");
const ResultOutput = @import("ArrayListOutput.zig");
const Asm = @import("Asm.zig");

const source =
    \\label: lbv 0x10
;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();

    var in = SourceInput.init(source);
    var out: ResultOutput = .{ .data = .init(alloc) };
    defer out.deinit();

    var @"asm" = Asm.init(alloc, &in);
    defer @"asm".deinit();
    @"asm".translate() catch |err| {
        switch (err) {
            error.OutOfMemory => std.debug.print("Out of memory\n", .{}),
            error.SyntaxError => {}, // error message already printed
        }
        return err;
    };

    // while (in.c) |byte| : (in.next()) {
    //     try out.writeByte(byte);
    // }

    //try out.print("ABCD", .{});
    //std.debug.print("{x}\n", .{out.data.items});
}
