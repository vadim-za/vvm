const std = @import("std");
const Label = @import("Label.zig");
const Parser = @import("Parser.zig");

table: std.ArrayList(Label),
finalized: bool = false,

pub fn init(alloc: std.mem.Allocator) @This() {
    return .{
        .table = .init(alloc),
    };
}

pub fn deinit(self: @This()) void {
    self.table.deinit();
}

pub fn push(self: *@This(), label: Label) !void {
    std.debug.assert(!self.finalized);
    try self.table.append(label);
}

pub fn finalize(self: *@This(), parser: *Parser) !void {
    std.debug.assert(!self.finalized);
    std.sort.heap(Label, self.table.items, {}, Label.lessThan);
    try self.checkDuplicates(parser);
    self.finalized = true;
}

pub fn find(self: *const @This(), stored_name: Label.StoredName) ?*const Label {
    return if (std.sort.binarySearch(
        Label,
        self.table.items,
        stored_name,
        Label.compare,
    )) |index| &self.table.items[index] else null;
}

fn checkDuplicates(self: @This(), parser: *Parser) !void {
    const items = self.table.items;
    const max_index = if (items.len > 0) items.len - 1 else return;

    // Search for the duplicate pair with the smallest line number
    // and store it into report
    var report: ?[2]usize = null;

    // max_index is excluded from iteration, so that we can safely use (index+1)
    for (0..max_index) |index| {
        if (items[index].sameNameAs(items[index + 1])) {
            // index+1 has larger line number than index,
            // so we want to report index+1 as duplicate of index
            const take = if (report) |r|
                items[index].line < items[r[0]].line
            else
                true;

            if (take)
                report = .{ index, index + 1 };
        }
    }

    if (report) |r|
        return parser.raiseErrorAtLine(
            items[r[0]].line,
            1,
            "duplicate label",
            .{},
        );
}
