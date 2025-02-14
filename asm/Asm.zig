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
    const source = try readSourceFile(
        alloc,
        source_file_path,
    );
    defer alloc.free(source);

    return translateSource(alloc, source, dest_buffer);
}

const ReadError = error{ ReadError, OutOfMemory };

fn readSourceFile(
    alloc: std.mem.Allocator,
    source_file_path: []const u8,
) ReadError![]const u8 {
    const file = std.fs.cwd().openFile(
        source_file_path,
        .{},
    ) catch {
        std.debug.print("Error opening file '{s}'\n", .{source_file_path});
        return error.ReadError;
    };
    defer file.close();

    const max_mbytes = 64;
    const file_contents = file.readToEndAlloc(
        alloc,
        max_mbytes * 1000 * 1024,
    ) catch {
        std.debug.print(
            "File '{s}' too big (bigger than {d}MB\n",
            .{ source_file_path, max_mbytes },
        );
        return error.ReadError;
    };

    return file_contents;
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
