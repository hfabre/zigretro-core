pub const Color = struct {
    a: u8,
    r: u8,
    g: u8,
    b: u8
};

pub const black = Color {
    .a = 0,
    .r = 0,
    .g = 0,
    .b = 0
};

pub const white = Color {
    .a = 0,
    .r = 255,
    .g = 255,
    .b = 255
};
