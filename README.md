# c64dev

The purpose of this repository is to provide a starting point for folks who are interested in Commodore 64 hobbyist programming.

I have organized [a collection of links on my Pinboard](https://pinboard.in/u:420/t:c64) that I find useful for C64 development. The bookmarks tagged [`start-here`](https://pinboard.in/u:420/t:c64/t:start-here) are most useful for absolute beginners, and the [`reference`](https://pinboard.in/u:420/t:c64/t:reference) tag is reserved for materials that I like to have handy when programming.

This repository is a work in progress, and I'm hoping to add a lot more documentation to ease the initial burden of setting up a C64 build-chain.

## To compile the examples here

Install [64tass](http://tass64.sourceforge.net) and [pucrunch](https://github.com/mist64/pucrunch) into your `$PATH`, then do

```
./compile.sh [folder name]
```

If your folder is named `foo`, then it should contain a file `foo.asm` that contains the main portion of your program and `.include`s all of your program's assets at the appropriate memory locations. 

This will generate a PRG file in the format `FOO.PRG`. All of the programs are placed in a `PROGRAMS` folder that you can easily copy to an SD card or mount with [uno2iec](https://github.com/jumpnow/meta-rpi/blob/krogoth/images/console-image.bb). You can also run the PRG files with a C64 emulator like [VICE](http://vice-emu.sourceforge.net/).
