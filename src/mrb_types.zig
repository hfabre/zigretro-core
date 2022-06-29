const mruby = @import("mruby");
const clr = @import("color.zig");
const std = @import("std");

pub const MrbColor = struct {
    a: mruby.mrb_int,
    r: mruby.mrb_int,
    g: mruby.mrb_int,
    b: mruby.mrb_int,

    pub fn to_color(self: *MrbColor) clr.Color {
        std.log.info("{s}", .{"converting to color"});
        return clr.Color {
            .a = @intCast(u8, self.a),
            .r = @intCast(u8, self.r),
            .g = @intCast(u8, self.g),
            .b = @intCast(u8, self.b)
        };
    }
};
