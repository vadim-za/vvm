const std = @import("std");
const VvmCore = @import("VvmCore");
const Asm = @import("Asm.zig");

name: []const u8,
bytes: VvmCore.Command.Bytes,
semantics: Semantics,

pub const Semantics = union(enum) {
    opcode: OpcodeCommand,
    meta: MetaCommand,
};

const OpcodeCommand = @import("OpcodeCommand.zig");

const MetaCommand = struct {
    handler: *const fn (@"asm": *Asm) void,
};

pub const MetaHandler = union(VvmCore.Command.Bytes) {
    opcode_only: *const fn (@"asm": *Asm) void,
    extra_byte: *const fn (@"asm": *Asm, byte: u8) void,
    extra_word: *const fn (@"asm": *Asm, word: u16) void,

    pub fn init(handler_func: anytype, command_name: []const u8) @This() {
        return switch (@TypeOf(handler_func)) {
            fn (vvm: *Vvm) void => .{
                .opcode_only = handler_func,
            },
            fn (vvm: *Vvm, byte: u8) void => .{
                .extra_byte = handler_func,
            },
            fn (vvm: *Vvm, word: u16) void => .{
                .extra_word = handler_func,
            },
            else => @compileError("Unsupported handler type for " ++ command_name),
        };
    }
};
