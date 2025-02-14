const std = @import("std");
const SourceInput = @import("SourceInput.zig");
const ArrayListOutput = @import("ArrayListOutput.zig");
const PassOutput = @import("PassOutput.zig");
const Parser = @import("Parser.zig");

pub fn translateSourceFile(
    alloc: std.mem.Allocator,
    source_file_path: []const u8,
    dest_buffer: *std.ArrayList(u8),
) (Parser.Error || ReadError)!void {
    var source: std.ArrayList(u8) = .init(alloc);
    defer source.deinit();
    try readSourceFile(source_file_path, &source);

    return translateSource(alloc, source.items, dest_buffer);
}

const ReadError = error{ ReadError, OutOfMemory };

fn readSourceFile(
    source_file_path: []const u8,
    file_contents: *std.ArrayList(u8),
) ReadError!void {
    const file = std.fs.cwd().openFile(
        source_file_path,
        .{},
    ) catch {
        std.debug.print("Error opening file '{s}'\n", .{source_file_path});
        return error.ReadError;
    };
    defer file.close();

    const max_mbytes = 64;
    file.reader().readAllArrayList(
        file_contents,
        max_mbytes * 1000 * 1024,
    ) catch {
        std.debug.print(
            "File '{s}' too big (bigger than {d}MB\n",
            .{ source_file_path, max_mbytes },
        );
        return error.ReadError;
    };
}

pub fn translateSource(
    alloc: std.mem.Allocator,
    source: []const u8,
    dest_buffer: *std.ArrayList(u8),
) Parser.Error!void {
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
