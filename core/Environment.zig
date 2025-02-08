ptr: ?*anyopaque,
vft: struct {
    in: *const fn (ptr: ?*anyopaque, port: u8) u8,
    out: *const fn (ptr: ?*anyopaque, port: u8, value: u8) void,
},

pub fn init(T: type, ptr: ?*T) @This() {
    return .{
        .ptr = ptr,
        .vft = .{
            .in = T.in,
            .out = T.out,
        },
    };
}

pub const default = @This().init(Default, null);

const Default = struct {
    fn in(_: ?*anyopaque, _: u8) u8 {
        return 0;
    }
    fn out(_: ?*anyopaque, _: u8, _: u8) void {}
};
