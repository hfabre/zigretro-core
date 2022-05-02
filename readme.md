# Dretro-core

This is a [libretro](https://www.libretro.com/index.php/api/) [core](https://docs.libretro.com/development/cores/developing-cores/) implementation. Keep in mind thats my first take on writing
a libretro core and my first time using [Zig](https://ziglang.org/).

At the moment this is a minimal implementation (a [skeletor](https://github.com/libretro/skeletor) port), it simply draw a background and a rectangle.

## Usage

Make sure to have dlang and zig installed and available into your path.

Build the core using zig:

```sh
zig build
```

Run [retroach](https://www.retroarch.com/), of course it should run with any [libretro front](https://docs.libretro.com/development/frontends/), but that's the one i'am using:

```sh
path/to/retroarch -v -L path/to/this/repo/lib/libzigretro-core.{dylib,so}
```

`-v` option is optional i use it to debug my core since it makes retroarch verbose.

## Steps

- Print a rectangle (Handle the frame buffer and draw a AA rectangle to it)
- Handle input
- Minimal game scene (moving square)

## Very uncertain next steps

- Handle audio
- Include [mruby](https://mruby.org/) so you can script your core in ruby
- Build a pico8 like platform
