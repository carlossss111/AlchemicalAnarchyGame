# Alchemical Anarchy
A Minesweeper Game for the Gameboy! Still heavily in progress!

![Title Screen](demo_1.png)

This one is my most ambitious projects yet as it is written in SM83 assembly (a mix between the i8080 and the Z80) for the original Nintendo Gameboy. It is intended for a Cartridge with 32KB of ROM alone.

The goal of the project is to write a good minesweeper game, complete with a title screen, score, art and music.

## Compiling

Compile into a .gb using the Makefile. This will require the [RGBDS toolchain](https://rgbds.gbdev.io/) to be installed.

```
make
```

## Compatibility

This game is intended for the Gameboy DMG-01, and would therefore be compatible with the CGB and the GBA.

It can be treated as a 'grey cartridge'.

## Usage

### Emulation
For a 1-1 experience emulating the gameboy I used and recommend [Sameboy](https://github.com/LIJI32/SameBoy). It has [very good accuracy](https://daid.github.io/GBEmulatorShootout/) and allows you to easily apply effects to the screen to make it look closer to the real thing.

For debugging I used and recommend [Emulicious](https://emulicious.net/). It has extensive tools that show memory, registers, tilemaps, objects and palettes. It can be used to step through the program and and stop at breakpoints hit by either the PC or by any memory access.

Any other Gameboy emulator should work. These ones can be run with the following commands:
```
sameboy bin/minesweeper.gb
emulicious bin/minesweeper.gb
```

### Real Hardware
After running `make`, take the .gb file and load it onto a **32kb cartridge** that is compatible with **GBxCart RW**. Hey presto, you have a real game! Easy!

![Real hardware](demo_2.jpg)

See: https://www.gbxcart.com/

## Libraries
I am using the hUGE library for audio because I am not a musical person.
Available here: https://nickfa.ro/wiki/hUGETracker

## Resources
I got a lot out of the following material helpfully provided by the community:
* [Pan Docs](https://gbdev.io/pandocs/)
* [Assembly Reference](https://rgbds.gbdev.io/docs/v0.9.4)
* [GBDev Tutorial](https://gbdev.io/gb-asm-tutorial/)
* [CC0 Hardware Headerfile](https://github.com/gbdev/hardware.inc)
* [Official Gameboy Programming Manual](https://archive.org/details/GameBoyProgManVer1.1/mode/2up)

