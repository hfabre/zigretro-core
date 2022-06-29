const mruby = @import("mruby");

pub const Color = struct {
    r: mruby.mrb_int,
    g: mruby.mrb_int,
    b: mruby.mrb_int
};

pub const black = Color {
    .r = 0,
    .g = 0,
    .b = 0
};

pub const white = Color {
    .r = 255,
    .g = 255,
    .b = 255
};
