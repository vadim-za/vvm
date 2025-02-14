const std = @import("std");
const VvmCore = @import("VvmCore");
const SourceInput = @import("SourceInput.zig");
const ArrayListOutput = @import("ArrayListOutput.zig");
const PassOutput = @import("PassOutput.zig");
const Parser = @import("Parser.zig");

// const source =
//     \\label12: lbv 0x10
// ;

const source = @embedFile("examples/test.vvma");

pub fn main() u8 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();

    var in = SourceInput.init(source);
    var code_out: ArrayListOutput = .{ .data = .init(alloc) };
    defer code_out.deinit();

    var parser: Parser = .init(alloc, &in);
    defer parser.deinit();

    runTranslationPass(&parser, null) catch return 1;
    runTranslationPass(&parser, &code_out) catch return 1;

    std.debug.print("{any}\n", .{code_out.data.items});

    return 0;
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

test "Test" {
    // Ensure the other tests are performed
    std.testing.refAllDecls(@This());
}
