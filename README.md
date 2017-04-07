kjchess
=======

kjchess is a simple chess-playing engine, implemented in Swift.

I've wanted to write a chess program since I was a teenager.  I'm finally doing it.  I don't expect this to play a strong game, and it won't be using any advanced chess implementation techniques.  I just want to have a chess program I wrote all by myself.


## Status

kjchess is not usable yet.  The following features are implemented:

- Can determine legal moves for a given position, except for these limitations:
    - Doesn't recognize castling.
    - Doesn't recognize _en passant_ captures.
- Implements enough of the UCI protocol that a game can be played with XBoard and the PolyGlot adapter.

kjchess is written in Swift, and requires features of macOS 10.12 Sierra.  It may be portable to other platforms by replacing the use of `os_log()` and other macOS-specific APIs.


## Building

The easiest way to build everything is to run this command from the top-level directory:

    make all

The binaries will be in the `build/Release` directory.

To run unit tests, execute this command:

    make test


## Running

`kjchess-cli` is the executable program.  It does not provide its own GUI or command-line playing interface:  It must be run as a chess engine with GUI that implements the UCI (Universal Chess Interface) protocol.

If you have [XBoard](https://www.gnu.org/software/xboard/) and [PolyGlot](https://chessprogramming.wikispaces.com/PolyGlot) installed, you can start a game with human as white and kjchess as black by executing this command:

    make play

Note: On macOS, XBoard and PolyGlot can be installed from [Homebrew](https://brew.sh) with `brew install xboard polyglot`.

`kjchess-cli` may work with other UCI user interfaces, but its UCI implementation is very rudimentary and has only been tested with XBoard and PolyGlot.

