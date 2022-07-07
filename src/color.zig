pub const Color = struct {
    r: u8,
    g: u8,
    b: u8
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
