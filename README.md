kjchess
=======

kjchess is a simple chess-playing engine, implemented in Swift.

I've wanted to write a chess program since I was a teenager.  I'm finally doing it.  I don't expect this to play a strong game, and it won't be using any advanced chess implementation techniques.  It's a toy, but it's all mine.


## Status

kjchess is usable, but not great.  The following features are implemented:

- Can determine legal moves for a given position.
- Uses minimax with alpha-beta pruning to determine best move.
- Implements enough of the UCI protocol that a game can be played with these chess UIs:
    - [XBoard](https://www.gnu.org/software/xboard/) and the [PolyGlot](https://chessprogramming.wikispaces.com/PolyGlot) adapter.
    - [Scid vs. Mac](http://scidvspc.sourceforge.net/#toc3)
    - [ChessX](http://chessx.sourceforge.net)

The biggest weaknesses right now is that the move search is slow (a search depth of 6 takes a few seconds per move on my 2013 MacBook Pro).  The engine also doesn't save any information between moves, or ponder during the opponent's move.

kjchess is written in Swift, and requires features of macOS 10.12 Sierra.


## Building

The easiest way to build everything is to run this command from the top-level directory:

    make all

The binaries will be in the `build/Release` directory.

To run unit tests, execute this command:

    make test


## Running

`kjchess-cli` is the executable program.  It does not provide its own GUI or command-line playing interface:  It must be run as a chess engine with a GUI chess application that implements the UCI (Universal Chess Interface) protocol.

If you have [XBoard](https://www.gnu.org/software/xboard/) and [PolyGlot](https://chessprogramming.wikispaces.com/PolyGlot) installed, you can start a game by executing this command:

    make play

Note: On macOS, XBoard and PolyGlot can be installed from [Homebrew](https://brew.sh) with `brew install xboard polyglot`.

`kjchess-cli` may work with other UCI user interfaes, but its UCI implementation is very rudimentary and has only been tested with XBoard and PolyGlot, Scid vs Mac, and ChessX.

### Command-line Options

`kjchess-cli` accepts these command-line options:

- `-h`, `--help`: Show command-line help
- `-t N`, `--concurrent-tasks=N`: Number of concurrent tasks (default 4)
- `-l`, `--enable-log`: Enable system log output
- `-d N`, `--search-depth=`N: Search depth (default 6)
- `-v`, `--version`: Show version information

