const std = @import("std");
const print = @import("std").debug.print;
const lr = @cImport(@cInclude("libretro.h"));

const video_width = 200;
const video_height = 150;
const bpp = 4;
const speed = 1;
const video_pixels = video_height * video_width;
const allocator = std.heap.c_allocator;

var player_x: i32 = 0;
var player_y: i32 = 0;
var key_map = std.AutoHashMap(c_uint, Key).init(allocator);

const Key = enum {
    up,
    down,
    left,
    right
};

const Color = struct {
    a: u8,
    r: u8,
    g: u8,
    b: u8
};

const black = Color {
    .a = 0,
    .r = 0,
    .g = 0,
    .b = 0
};

const white = Color {
    .a = 0,
    .r = 255,
    .g = 255,
    .b = 255
};

// Logic

export fn retro_run() void {
    process_inputs();
    draw_rectangle(0, 0, video_width, video_height, black);
    draw_rectangle(player_x, player_y, 20, 20, white);
    screen_to_frame_buffer();
    video_cb.?(@ptrCast(*anyopaque, frame_buffer.ptr), video_width, video_height, bpp * video_width * @sizeOf(u8));
}

fn process_inputs() void {
    var it = key_map.iterator();

    while (it.next()) |kv| {
        var pressed = input_state_cb.?(0, lr.RETRO_DEVICE_JOYPAD, 0, kv.key_ptr.*);

        if (pressed != 0) {
            switch (kv.value_ptr.*) {
                Key.up => player_y -= speed,
                Key.down => player_y += speed,
                Key.right => player_x += speed,
                Key.left => player_x -= speed
            }
        }
    }
}

// Utils functions

fn draw_rectangle(x: i32, y: i32, w: i32, h: i32, color: Color) void {
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

fn screen_to_frame_buffer() void {
    var y: usize = 0;

    while (y < video_height) {
        var x: usize = 0;

        while (x < video_width) {
            var pixel = screen[y][x];
            var pixel_index = y * video_width + x;
            var base_index = pixel_index * bpp;

            frame_buffer[base_index] = pixel.r;
            frame_buffer[base_index + 1] = pixel.g;
            frame_buffer[base_index + 2] = pixel.b;
            frame_buffer[base_index + 3] = pixel.a;
            x += 1;
        }
        y += 1;
    }
}


// Init

var frame_buffer: []u8 = undefined;
var screen: [video_height][video_width]Color = undefined;

export fn retro_init() void {
    frame_buffer = allocator.alloc(u8, video_pixels * bpp) catch {
        handle_error("Could not allocate memory");
        // Trick to avoid error: expected type '[]u8', found 'void'
        return;
    };

    key_map.put(lr.RETRO_DEVICE_ID_JOYPAD_UP, Key.up) catch {
        handle_error("Could not allocate memory");
    };

    key_map.put(lr.RETRO_DEVICE_ID_JOYPAD_DOWN, Key.down) catch {
        handle_error("Could not allocate memory");
    };

    key_map.put(lr.RETRO_DEVICE_ID_JOYPAD_RIGHT, Key.right) catch {
        handle_error("Could not allocate memory");
    };

    key_map.put(lr.RETRO_DEVICE_ID_JOYPAD_LEFT, Key.left) catch {
        handle_error("Could not allocate memory");
    };
}

fn handle_error(message: []const u8) void {
    std.log.info("{s}", .{message});
    // TODO: environ_cb.?(lr.RETRO_ENVIRONMENT_SHUTDOWN, null)
    std.os.exit(1);
}

export fn retro_deinit() void {
    allocator.free(frame_buffer);
    key_map.deinit();
}

export fn retro_set_environment(cb: lr.retro_environment_t) void {
    environ_cb = cb;
    var allow_no_game = true;

    if (cb.?(lr.RETRO_ENVIRONMENT_GET_LOG_INTERFACE, &logging)) {
        log_cb = logging.log;
    }

     if (cb.?(lr.RETRO_ENVIRONMENT_SET_SUPPORT_NO_GAME, &allow_no_game)) {}
     else {
        print("Unable to allow no game booting\n", .{});
        return;
     }
}

export fn retro_load_game(_: [*c]lr.retro_game_info) bool {
    // Use a format where one pixel is composed by 4 bytes (A - R - G - B each of them is 1 byte)
    var fmt = lr.RETRO_PIXEL_FORMAT_XRGB8888;
    if (!environ_cb.?(lr.RETRO_ENVIRONMENT_SET_PIXEL_FORMAT, &fmt))
    {
        print("XRGB8888 is not supported.\n", .{});
        return false;
    }

    return true;
}

// Setting up callbacks

var logging: lr.retro_log_callback = undefined;
var log_cb: lr.retro_log_printf_t = undefined;
var environ_cb: lr.retro_environment_t = undefined;
var video_cb: lr.retro_video_refresh_t = undefined;
var audio_cb: lr.retro_audio_sample_t = undefined;
var audio_batch_cb: lr.retro_audio_sample_batch_t = undefined;
var input_poll_cb: lr.retro_input_poll_t = undefined;
var input_state_cb: lr.retro_input_state_t = undefined;

export fn retro_set_audio_sample(cb: lr.retro_audio_sample_t) void {
    audio_cb = cb;
}

export fn retro_set_audio_sample_batch(cb: lr.retro_audio_sample_batch_t) void {
    audio_batch_cb = cb;
}

export fn retro_set_input_poll(cb: lr.retro_input_poll_t) void {
    input_poll_cb = cb;
}

export fn retro_set_input_state(cb: lr.retro_input_state_t) void {
    input_state_cb = cb;
}

export fn retro_set_video_refresh(cb: lr.retro_video_refresh_t) void {
    video_cb = cb;
}

// Setting informations

export fn retro_get_system_info(info: [*c]lr.struct_retro_system_info) void {
    info.*.library_name = "zigretro";
    info.*.library_version = "0.1";
    info.*.need_fullpath = true;
    info.*.valid_extensions = "";
}

export fn retro_get_system_av_info(info: [*c]lr.retro_system_av_info) void {
    info.*.geometry.base_width = video_width;
    info.*.geometry.base_height = video_height;
    info.*.geometry.max_width = video_width;
    info.*.geometry.max_height = video_height;
    info.*.geometry.aspect_ratio = 0.0;
}

// Mandatory symbols

export fn retro_api_version() c_uint {
   return lr.RETRO_API_VERSION;
}

export fn retro_set_controller_port_device(_: c_uint, _: c_uint) void {

}


export fn retro_reset() void {

}

export fn audio_callback() void {

}

export fn audio_set_state(_: bool) void {

}

export fn retro_unload_game() void {

}

export fn retro_get_region() c_uint {
    return lr.RETRO_REGION_NTSC;
}

export fn retro_load_game_special(_: c_uint, _: [*c]lr.retro_game_info, _: usize) bool {
    return false;
}

export fn retro_serialize_size() usize {
    return 0;
}

export fn retro_serialize(_: *anyopaque, _: usize) bool {
    return false;
}

export fn retro_unserialize(_: *anyopaque, _: usize) bool {
    return false;
}

export fn retro_get_memory_data(_: c_uint) ?*anyopaque {
    return null;
}

export fn retro_get_memory_size(_: c_uint) usize {
    return 0;
}

export fn retro_cheat_reset() void {

}

export fn retro_cheat_set(_: c_uint, _: bool, _: [*c]u8) void {

}
