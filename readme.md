# Dretro-core

This is a [libretro](https://www.libretro.com/index.php/api/) [core](https://docs.libretro.com/development/cores/developing-cores/) implementation. Keep in mind thats my first take on writing
a libretro core and my first time using [Zig](https://ziglang.org/).

At the moment this is a very simple game scene with a moving square which you can script using [mruby](https://github.com/dantecatalfamo/mruby-zig).
To do so, simply edit the `game.rb` file as you want.

## Usage

Make sure to have Zig installed and available into your path.
If you have done any changes to the mruby tree, don't forget to build it again.

```sh
cd mruby/mruby
./minirake
```

Build the core using zig:

```sh
zig build
```

Run [retroach](https://www.retroarch.com/), of course it should run with any [libretro front](https://docs.libretro.com/development/frontends/), but that's the one i'am using:

```sh
path/to/retroarch -v -L path/to/this/repo/lib/libzigretro-core.{dylib,so} ./src/game.rb
```

`-v` option is optional i use it to debug my core since it makes retroarch verbose.

## Steps

- Think to a better way to share input from core to ruby script

## Very uncertain next steps

- Handle audio
- Build a pico8 like platform
