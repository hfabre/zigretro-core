const std = @import("std");
const clr = @import("color.zig");

// Trick: i have some trouble to implement this inside the Engine struct
// Got some tips about using allocation but prefer to avoid if possible
// Or generics but i find it too much for what i need
var screen: [Engine.height][Engine.width]clr.Color = undefined;

pub const Engine = struct {
    pub const bpp = 4;
    pub const speed = 1;
    pub const width: u32 = 200;
    pub const height: u32 = 150;

    width: u32,
    height: u32,
    screen_size:  u32,
    pitch: u32,
    framebuffer: []u8,
    allocator: std.mem.Allocator,
    // TODO: Extract this in a GameState
    x: u32,
    y: u32,


    pub fn init(allocator: std.mem.Allocator) !Engine {
        var screen_size = width * height;
        var framebuffer = try allocator.alloc(u8, screen_size * bpp);

        return Engine {
            .allocator = allocator,
            .width = width,
            .height = height,
            .screen_size = screen_size,
            .pitch = bpp * width * @sizeOf(u8),
            .framebuffer = framebuffer,
            .x = 0,
            .y = 0
        };
    }

    pub fn deinit(self: Engine) void {
        self.allocator.free(self.framebuffer);
    }

    pub fn run(self: Engine) void {
        self.draw_rectangle(0, 0, self.width, self.height, clr.black);
        self.draw_rectangle(self.x, self.y, 20, 20, clr.white);
        self.screen_to_frame_buffer();
    }

    pub fn up_pressed(self: *Engine) void {
        self.y -= speed;
    }

    pub fn down_pressed(self: *Engine) void {
        self.y += speed;
    }

    pub fn right_pressed(self: *Engine) void {
        self.x += speed;
    }

    pub fn left_pressed(self: *Engine) void {
        self.x -= speed;
    }

    fn screen_to_frame_buffer(self: Engine) void {
        var y: usize = 0;

        while (y < self.height) {
            var x: usize = 0;

            while (x < width) {
                var pixel = screen[y][x];
                var pixel_index = y * width + x;
                var base_index = pixel_index * bpp;

                self.framebuffer[base_index] = pixel.r;
                self.framebuffer[base_index + 1] = pixel.g;
                self.framebuffer[base_index + 2] = pixel.b;
                self.framebuffer[base_index + 3] = pixel.a;
                x += 1;
            }
            y += 1;
        }
    }

    fn draw_rectangle(_: Engine, x: u32, y: u32, w: u32, h: u32, color: clr.Color) void {
        var i: usize = @intCast(usize, y);

        while (i < y + h) {
            var j: usize = @intCast(usize, x);

            while (j < x + w) {
                screen[i][j] = color;
                j += 1;
            }
            i += 1;
        }
    }
};
