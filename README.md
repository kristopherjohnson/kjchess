kjchess
=======

kjchess is a simple chess-playing engine, implemented in Swift.

I've wanted to write a chess program since I was a teenager.  I'm finally doing it.  I don't expect this to be a strong player, and it won't be using any advanced chess implementation techniques.  I just want to have my own chess program.

## Status

kjchess is not usable yet.  The following features are implemented:

- Can represent a position.
- Can apply moves to a position.
- Can determine legal moves for a position (except castling and en passant)

Currently working on UCI protocol implementation so that kjchess can be used as an engine with a UCI-compatible GUI.

