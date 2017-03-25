//
//  Board.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

/// Chess board.
///
/// Representation is an 8x8 array.
/// Each element may be a `Piece` or be empty (`nil`).
///
/// A `Board` is an immutable object.  Moves result in
/// the creation of new `Board` instances, which may
/// share rank arrays with other instances.
public struct Board {
    public static let ranksCount = 8
    public static let filesCount = 8

    public static let minRank = 0
    public static let maxRank = ranksCount - 1

    public static let minFile = 0
    public static let maxFile = filesCount - 1

    public static let squaresCount = ranksCount * filesCount

    /// Return true if the given file index is in the range 0...7.
    public static func isValid(file: Int) -> Bool {
        return (minFile...maxFile).contains(file)
    }

    /// Return true if the given rank index is in the range 0...7.
    public static func isValid(rank: Int) -> Bool {
        return (minRank...maxRank).contains(rank)
    }

    /// Return true if given file and rank are in the range 0...7.
    public static func isValid(file: Int, rank: Int) -> Bool {
        return isValid(file: file) && isValid(rank: rank)
    }

    public static let empty
        = Board(Array(repeating: nil, count: Board.squaresCount))

    public static let newGame
        = Board([WR,  WN,  WB,  WQ,  WK,  WB,  WN,  WR,
                 WP,  WP,  WP,  WP,  WP,  WP,  WP,  WP,
                 nil, nil, nil, nil, nil, nil, nil, nil,
                 nil, nil, nil, nil, nil, nil, nil, nil,
                 nil, nil, nil, nil, nil, nil, nil, nil,
                 nil, nil, nil, nil, nil, nil, nil, nil,
                 BP,  BP,  BP,  BP,  BP,  BP,  BP,  BP,
                 BR,  BN,  BB,  BQ,  BK,  BB,  BN,  BR])

    public let squares: [Piece?]

    public init(_ squares: [Piece?]) {
        assert(squares.count == Board.squaresCount,
               "Number of squares must be 64")
        self.squares = squares
    }

    /// Return `Piece` at the specified `Location`.
    public subscript(location: Location) -> Piece? {
        return squares[location.rank * Board.filesCount + location.file]
    }

    /// Return `Piece` at the specified location.
    public func at(file: Int, rank: Int) -> Piece? {
        return squares[rank * Board.filesCount + file]
    }

    /// Return `true` if specified `Location` has no piece on it.
    public func isEmpty(_ location: Location) -> Bool {
        return self[location] == nil
    }

    /// Return `true` if specified square has no piece on it.
    public func isEmpty(file: Int, rank: Int) -> Bool {
        return at(file: file, rank: rank) == nil
    }

    /// Return `true` if specified square has a piece of the specified color.
    public func hasPiece(file: Int, rank: Int, player: Player) -> Bool {
        if let piece = at(file: file, rank: rank), piece.player == player {
            return true
        }
        return false
    }

    /// Return copy of board after applying the given `Move`.
    ///
    /// This method does not validate whether the move is valid
    /// of the specified pieces exist.
    public func after(_ move: Move) -> Board {
        switch move {

        case .move(let piece, let from, let to),
             .capture(let piece, let from, let to, _):
            return self.with([(piece, to),
                              (nil, from)])

        case .promote:
            return self

        case .promoteCapture:
            return self
            
        case .enPassantCapture(let player, let from, let to):
            let capturedPieceRank
                = (player == .white)
                    ? to.rank - 1
                    : to.rank + 1
            return self
                .with([(Piece(player, .pawn), to),
                       (nil, from),
                       (nil, Location(to.file, capturedPieceRank))])

        case .castleKingside(let player):
            switch player {
            case .white:
                return self.with([(WK,  g1),
                                  (WR,  f1),
                                  (nil, e1),
                                  (nil, h1)])
            case .black:
                return self.with([(BK,  g8),
                                  (BR,  f8),
                                  (nil, e8),
                                  (nil, h8)])
            }

        case .castleQueenside(let player):
            switch player {
            case .white:
                return self.with([(WK,  c1),
                                  (WR,  d1),
                                  (nil, e1),
                                  (nil, a1)])
            case .black:
                return self.with([(BK,  c8),
                                  (BR,  d8),
                                  (nil, e8),
                                  (nil, a8)])
            }

        case .resign:
            return self
        }
    }

    /// Return copy of board with the given `Piece` at the given `Location`.
    public func with(_ piece: Piece?, at location: Location) -> Board {
        var newSquares = Array(squares)
        newSquares[location.rank * Board.filesCount + location.file] = piece

        return Board(newSquares)
    }

    /// Return copy of board with the given `Pieces` at the given `Locations`.
    public func with(_ pieceLocations: [(Piece?, Location)]) -> Board {
        var newSquares = Array(squares)

        for (piece, location) in pieceLocations {
            newSquares[location.rank * Board.filesCount + location.file] = piece
        }

        return Board(newSquares)
    }

    /// Return array of (`Piece`, `Location`) tuples indicating pieces for the specified player.
    public func pieces(player: Player) -> AnySequence<(Piece, Location)> {
        // TODO: Create the result sequence lazily
        var result = [(Piece, Location)]()
        for rank in 0..<Board.ranksCount {
            let file0 = rank * Board.filesCount
            for file in 0..<Board.filesCount {
                let index = file0 + file
                if let piece = squares[index], piece.player == player {
                    result.append((piece, Location(file, rank)))
                }
            }
        }
        return AnySequence(result)
    }
}
