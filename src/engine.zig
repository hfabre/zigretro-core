const std = @import("std");
const mruby = @import("mruby");
const clr = @import("color.zig");
const main = @import("main.zig");

// Trick: i have some trouble to implement this inside the Engine struct
// Got some tips about using allocation but prefer to avoid if possible
// Or generics but i find it too much for what i need
var screen: [Engine.height][Engine.width]clr.Color = undefined;
var color_class: *mruby.RClass = undefined;

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
    mrb: *mruby.mrb_state,
    // TODO: Extract this in a GameState
    x: u32,
    y: u32,

    pub fn init(allocator: std.mem.Allocator) !Engine {
        std.log.info("booting engine", .{});
        var screen_size = width * height;
        var framebuffer = try allocator.alloc(u8, screen_size * bpp);

        std.log.info("init mruby", .{});
        // var mrb_alloc = mruby.MrubyAllocator.init(allocator);
        // var new_mrb = try mruby.open_allocator(&mrb_alloc);
        var new_mrb = try mruby.open();

        std.log.debug("setup color class", .{});
        color_class = try new_mrb.define_class("Color", new_mrb.object_class());
        new_mrb.define_method(color_class, "initialize", mrb_initialize_color, .{ .req = 0 });

        new_mrb.define_module_function(new_mrb.kernel_module(), "draw_rect", mrb_draw_rect, .{ .req = 5 });

        std.log.info("load mruby game", .{});
        _ = try new_mrb.load_file("/Users/hfabre/local/perso/zig/zigretro-core/src/game.rb");

        std.log.info("engine ready", .{});
        return Engine {
            .allocator = allocator,
            .width = width,
            .height = height,
            .screen_size = screen_size,
            .pitch = bpp * width * @sizeOf(u8),
            .framebuffer = framebuffer,
            .mrb = new_mrb,
            .x = 0,
            .y = 0
        };
    }

    pub fn deinit(self: Engine) void {
        self.mrb.close();
        self.allocator.free(self.framebuffer);
    }

    pub fn run(self: Engine) void {
        self.draw_rectangle(0, 0, self.width, self.height, clr.black);
        _ = self.mrb.funcall(self.mrb.kernel_module().value(), "run", .{});
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

                self.framebuffer[base_index] = @intCast(u8, pixel.r);
                self.framebuffer[base_index + 1] = @intCast(u8, pixel.g);
                self.framebuffer[base_index + 2] = @intCast(u8, pixel.b);
                self.framebuffer[base_index + 3] = 0; // Libretro does not handle transparency
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

// Mruby things

pub export fn mrb_initialize_color(mrb: *mruby.mrb_state, self: mruby.mrb_value) mruby.mrb_value {
    mrb.iv_set(self, mrb.intern("@r"), mrb.int_value(255));
    mrb.iv_set(self, mrb.intern("@g"), mrb.int_value(255));
    mrb.iv_set(self, mrb.intern("@b"), mrb.int_value(255));
    return self;
}

pub export fn mrb_draw_rect(mrb: *mruby.mrb_state, self: mruby.mrb_value) mruby.mrb_value {
    var x: mruby.mrb_int = 0;
    var y: mruby.mrb_int = 0;
    var w: mruby.mrb_int = 0;
    var h: mruby.mrb_int = 0;
    var mrb_color: mruby.mrb_value = undefined;

    _ = mrb.get_args("iiiio", .{ &x, &y, &w, &h, &mrb_color });

    const r = mrb.iv_get(mrb_color, mrb.intern("@r")).integer() catch unreachable;
    const g = mrb.iv_get(mrb_color, mrb.intern("@g")).integer() catch unreachable;
    const b = mrb.iv_get(mrb_color, mrb.intern("@b")).integer() catch unreachable;
    var c = clr.Color {
        .r = r,
        .g = g,
        .b = b,
    };
    main.engine.draw_rectangle(@intCast(u32, x), @intCast(u32, y), @intCast(u32, w), @intCast(u32, h), c);
    return self;
}
