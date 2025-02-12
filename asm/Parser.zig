const std = @import("std");
const SourceInput = @import("SourceInput.zig");
const LineInput = @import("LineInput.zig");
const ResultOutput = @import("ArrayListOutput.zig");
const Label = @import("Label.zig");

source_in: *SourceInput,
line_in: LineInput,
current_line_number: usize,
current_pos_number: usize,
labels: std.ArrayList(Label),

pub fn init(alloc: std.mem.Allocator, source_in: *SourceInput) @This() {
    const line_in: LineInput = .init(source_in);
    return .{
        .source_in = source_in,
        .line_in = line_in,
        .current_line_number = 1,
        .current_pos_number = line_in.current_pos_number,
        .labels = .init(alloc),
    };
}

pub fn deinit(self: *const @This()) void {
    self.labels.deinit();
}

pub const Error = error{ SyntaxError, OutOfMemory };

pub fn translate(self: *@This()) Error!void {
    if (try self.readLine() == null)
        return;
    self.current_line_number += 1;
}

fn readLine(self: *@This()) !?void {
    const in = &self.line_in;
    if (in.c == null)
        return null;

    self.current_pos_number = in.current_pos_number;
    if (!in.isAtWhitespace())
        try self.readLabel();

    self.skipWhitespace();
    try self.readCommand();
}

fn readCommand(self: *@This()) !void {
    _ = self; // autofix
}

fn readLabel(self: *@This()) !void {
    const in = &self.line_in;
    var id_bytes: std.BoundedArray(u8, Label.max_length) = .{};

    if (!in.isAtAlphabetic())
        return self.raiseError("Label must begin with a letter", .{});

    id_bytes.append(in.c.?) catch unreachable; // there must be always space for one character
    in.next();

    while (in.isAtAlphanumeric()) {
        id_bytes.append(in.c.?) catch
            return self.raiseError(
            "label too long (max length = {})",
            .{Label.max_length},
        );
        in.next();
    }

    self.skipWhitespace();
    if (in.c != ':')
        return self.raiseError("label must be followed by a colon", .{});
    in.next();

    const label = Label.init(
        id_bytes.constSlice(),
        self.current_line_number,
    );
    try self.labels.append(label);
}

pub fn skipWhitespace(self: *@This()) void {
    const in = &self.line_in;
    while (in.isAtWhitespace())
        in.next();
    self.current_pos_number = in.current_pos_number;
}

pub fn raiseError(self: *@This(), comptime fmt: []const u8, args: anytype) !void {
    std.debug.print(
        "({}:{}) " ++ fmt ++ "\n",
        .{
            self.current_line_number,
            self.current_pos_number,
        } ++ args,
    );
    return error.SyntaxError;
}
