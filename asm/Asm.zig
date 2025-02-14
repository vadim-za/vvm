const std = @import("std");
const SourceInput = @import("SourceInput.zig");
const ArrayListOutput = @import("ArrayListOutput.zig");
const PassOutput = @import("PassOutput.zig");
const Parser = @import("Parser.zig");

// The owner is responsible for freeing the returned slice
pub fn translateSource(
    alloc: std.mem.Allocator,
    source: []const u8,
    dest_buffer: *std.ArrayList(u8),
) !void {
    var in = SourceInput.init(source);
    var out: ArrayListOutput = .{ .data = dest_buffer };

    var parser: Parser = .init(alloc, &in);
    defer parser.deinit();

    try runTranslationPass(&parser, null);
    try runTranslationPass(&parser, &out);
}

fn runTranslationPass(parser: *Parser, out: ?*ArrayListOutput) !void {
    var pass_output: PassOutput = .init(out);

    parser.translate(&pass_output) catch |err| {
        switch (err) {
            error.OutOfMemory => std.debug.print("Out of memory\n", .{}),
            error.SyntaxError => {}, // error message already printed
        }
        return err;
    };
}
