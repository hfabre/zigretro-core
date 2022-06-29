# Dretro-core

This is a [libretro](https://www.libretro.com/index.php/api/) [core](https://docs.libretro.com/development/cores/developing-cores/) implementation. Keep in mind thats my first take on writing
a libretro core and my first time using [Zig](https://ziglang.org/).

At the moment this is a very simple implementation but it includes [mruby](https://github.com/dantecatalfamo/mruby-zig)
so the core can be scripted using it.

## Usage

Make sure to have Zig installed and available into your path.

If you have done any changes to the mruby tree, don't forget to build it again.
To do so, you will need to insall [rake](https://github.com/ruby/rake)

```sh
cd mruby/mruby
rake
```

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
- Include [mruby](https://mruby.org/) so you can script your core in ruby

## Very uncertain next steps

- Handle audio
- Build a pico8 like platform
