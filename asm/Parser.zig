const std = @import("std");
const SourceInput = @import("SourceInput.zig");
const PassOutput = @import("PassOutput.zig");
const LineInput = @import("LineInput.zig");
const Label = @import("Label.zig");
const Labels = @import("Labels.zig");
const commands = @import("commands.zig");
const builtin = @import("builtin");

source_in: *SourceInput,
line_in: LineInput,
current_line_number: usize,
labels: Labels,
pc: u16,
error_info: ?*?ErrorInfo,

pub fn init(
    alloc: std.mem.Allocator,
    source_in: *SourceInput,
    error_info: ?*?ErrorInfo,
) @This() {
    var self = @This(){
        .source_in = source_in,
        .line_in = .init(source_in),
        .current_line_number = undefined,
        .labels = .init(alloc),
        .pc = undefined,
        .error_info = error_info,
    };

    self.reset();
    return self;
}

pub fn deinit(self: *const @This()) void {
    self.labels.deinit();
}

pub const StoredInputState = struct {
    source_in: SourceInput,
    line_in: LineInput,
    current_line_number: usize,
};

pub fn storeInputState(self: @This()) StoredInputState {
    return .{
        .source_in = self.source_in.*,
        .line_in = self.line_in,
        .current_line_number = self.current_line_number,
    };
}

pub fn restoreInputState(self: *@This(), stored: StoredInputState) void {
    self.source_in.* = stored.source_in;
    self.line_in = stored.line_in;
    self.current_line_number = stored.current_line_number;
}

pub fn reset(self: *@This()) void {
    self.source_in.reset();
    self.current_line_number = 1;
    self.pc = 0;
}

pub const Error = error{ SyntaxError, OutOfMemory };

pub fn translate(self: *@This(), out: *PassOutput) Error!void {
    self.reset();

    while (self.source_in.c != null) : (self.current_line_number += 1) {
        self.line_in.reset();
        try self.parseLine(out);
    }

    if (out.underlying == null)
        try self.labels.finalize(self);
}

fn parseLine(self: *@This(), out: *PassOutput) !void {
    const in = &self.line_in;
    if (in.c == null)
        return;

    if (!in.isAtWhitespace()) {
        if (try self.tryParseCommentHere())
            return;
        try self.parseLabelDefinitionHere();
    }

    self.skipWhitespace();
    if (in.c == null)
        return; // no command

    if (try self.tryParseCommentHere())
        return;
    try self.parseCommandAreaHere(out);

    self.skipWhitespace();
    if (try self.tryParseCommentHere())
        return;

    if (in.c != null)
        return self.raiseError(
            in.current_pos_number,
            "end of line expected",
            .{},
        );
}

fn parseCommandAreaHere(self: *@This(), out: *PassOutput) !void {
    if (try self.tryParseMetaCommandHere(out))
        return;
    try self.parseCommandHere(out);
}

fn tryParseCommentHere(self: *@This()) !bool {
    const in = &self.line_in;
    if (in.c != ';')
        return false;

    while (in.c != null)
        in.next();

    return true;
}

pub fn requireAndSkipWhitespace(self: *@This()) !void {
    const in = &self.line_in;
    const pos = in.current_pos_number;

    if (!in.isAtWhitespace())
        return self.raiseError(pos, "whitespace expected", .{});
    self.skipWhitespace();
}

pub fn skipWhitespace(self: *@This()) void {
    const in = &self.line_in;
    while (in.isAtWhitespace())
        in.next();
}

const parseLabelDefinitionHere =
    @import("parser/label.zig").parseLabelDefinitionHere;

const parseCommandHere =
    @import("parser/command.zig").parseCommandHere;

const tryParseMetaCommandHere =
    @import("parser/meta_command.zig").tryParseMetaCommandHere;

pub fn raiseError(
    self: *@This(),
    pos: usize,
    comptime fmt: []const u8,
    args: anytype,
) error{SyntaxError} {
    return self.raiseErrorAtLine(
        self.current_line_number,
        pos,
        fmt,
        args,
    );
}

pub fn raiseErrorAtLine(
    self: *@This(),
    line: usize,
    pos: usize,
    comptime fmt: []const u8,
    args: anytype,
) error{SyntaxError} {
    if (self.error_info) |info|
        info.* = .{ .line = line, .pos = pos };

    if (!builtin.is_test)
        std.debug.print(
            "({}:{}) " ++ fmt ++ "\n",
            .{
                line,
                pos,
            } ++ args,
        );

    return error.SyntaxError;
}

pub const ErrorInfo = struct {
    line: usize,
    pos: usize,

    pub fn isAt(self: @This(), line: usize, pos: usize) bool {
        return self.line == line and self.pos == pos;
    }
};
