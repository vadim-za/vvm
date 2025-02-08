ptr: ?*anyopaque,
vft: struct {
    in: *const fn (ptr: ?*anyopaque, port: u8) u8,
    out: *const fn (ptr: ?*anyopaque, port: u8, value: u8) void,
},

pub fn init(T: type, ptr: ?*T) @This() {
    return .{
        .ptr = ptr,
        .vft = .{
            .in = T.envIn,
            .out = T.envOut,
        },
    };
}

pub const default = @This().init(Default, null);

const Default = struct {
    fn envIn(_: ?*anyopaque, _: u8) u8 {
        return 0;
    }
    fn envOut(_: ?*anyopaque, _: u8, _: u8) void {}
};
