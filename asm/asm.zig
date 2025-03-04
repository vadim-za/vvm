const std = @import("std");
const SourceInput = @import("SourceInput.zig");
const ArrayListOutput = @import("ArrayListOutput.zig");
const PassOutput = @import("PassOutput.zig");
const Parser = @import("Parser.zig");

// The caller must call deinit() on returned value
pub fn translateSourceFile(
    alloc: std.mem.Allocator,
    source_file_path: []const u8,
) (Parser.Error || ReadError)!std.ArrayList(u8) {
    var source: std.ArrayList(u8) = .init(alloc);
    defer source.deinit();
    try readSourceFile(source_file_path, &source);

    return translateSource(alloc, source.items, null);
}

const ReadError = error{ReadError};

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

// The caller must call deinit() on returned value
pub fn translateSource(
    alloc: std.mem.Allocator,
    source: []const u8,
    error_info: ?*?Parser.ErrorInfo,
) Parser.Error!std.ArrayList(u8) {
    var in = SourceInput.init(source);
    var parser: Parser = .init(alloc, &in, error_info);
    defer parser.deinit();

    var out_data: std.ArrayList(u8) = .init(alloc);
    errdefer out_data.deinit();
    var out: ArrayListOutput = .{ .data = &out_data };

    try runTranslationPass(&parser, null);
    try runTranslationPass(&parser, &out);

    return out_data;
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

comptime {
    // Ensure the other tests are performed
    std.testing.refAllDecls(@This());
}

// Test helpers

pub const TranslateSourceErrorTest = // { source, expected_error_info }
    struct { []const u8, ?Parser.ErrorInfo.InitTuple };

pub fn testTranslateSourceErrors(tests: []const TranslateSourceErrorTest) !void {
    for (tests) |t| {
        const source = t[0];
        const expected_error = t[1];

        var error_info: ?Parser.ErrorInfo = null;
        const result = translateSource(
            std.testing.allocator,
            source,
            &error_info,
        );
        defer {
            // Deinit only if not error
            if (result) |container| container.deinit() else |_| {}
        }

        if (expected_error) |exp| {
            try std.testing.expectEqual(error.SyntaxError, result);
            try std.testing.expect(error_info.?.eqTuple(exp));
        } else {
            _ = try result; // fail upon a returned error
        }
    }
}
