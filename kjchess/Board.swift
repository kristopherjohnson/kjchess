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

    /// The array that holds the board state.
    ///
    /// The array has 64 elements.  The first 8 are for squares
    /// a1-a8, the next 8 are for b1-b8, and so on.
    ///
    /// `squares` is not marked `public` or `private`.  It should
    /// be treated as if it's `private` to the `Board` type and
    /// its extensions, but Swift 3 doesn't provide that kind of
    /// access control specification.
    var squares: [Piece?]

    public init(_ squares: [Piece?]) {
        assert(squares.count == Board.squaresCount,
               "Number of squares must be 64")
        self.squares = squares
    }

    /// Given an index into the `squares` array, return the associated `Location`.
    public func location(squareIndex: Int) -> Location {
        return Location(squareIndex % Board.filesCount,
                        squareIndex / Board.filesCount)
    }

    /// Given a location, return the associated index into the `squares` array.
    public func squareIndex(location: Location) -> Int {
        return location.file + location.rank * Board.filesCount
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
            return self.with((piece, to),
                             (nil, from))

        case .promote(let player, let from, let to, let promoted),
             .promoteCapture(let player, let from, let to, _, let promoted):
            return self.with((Piece(player, promoted), to),
                             (nil, from))
            
        case .enPassantCapture(let player, let from, let to):
            let captureRank = (player == .white) ? to.rank - 1 : to.rank + 1
            let capturedPawnLocation = Location(to.file, captureRank)
            return self
                .with((Piece(player, .pawn), to),
                      (nil, from),
                      (nil, capturedPawnLocation))

        case .castleKingside(let player):
            switch player {
            case .white:
                return self.with((WK,  g1),
                                 (WR,  f1),
                                 (nil, e1),
                                 (nil, h1))
            case .black:
                return self.with((BK,  g8),
                                 (BR,  f8),
                                 (nil, e8),
                                 (nil, h8))
            }

        case .castleQueenside(let player):
            switch player {
            case .white:
                return self.with((WK,  c1),
                                 (WR,  d1),
                                 (nil, e1),
                                 (nil, a1))
            case .black:
                return self.with((BK,  c8),
                                 (BR,  d8),
                                 (nil, e8),
                                 (nil, a8))
            }

        case .resign:
            return self
        }
    }

    /// Applying the given `Move` to the `Board`, modifying it.
    ///
    /// This method does not validate whether the move is valid
    /// of the specified pieces exist.
    public mutating func apply(_ move: Move) {
        switch move {

        case .move(let piece, let from, let to),
             .capture(let piece, let from, let to, _):
            squares[squareIndex(location: from)] = nil
            squares[squareIndex(location: to)] = piece

        case .promote(let player, let from, let to, let promoted),
             .promoteCapture(let player, let from, let to, _, let promoted):
            squares[squareIndex(location: from)] = nil
            squares[squareIndex(location: to)] = Piece(player, promoted)

        case .enPassantCapture(let player, let from, let to):
            let captureRank = (player == .white) ? to.rank - 1 : to.rank + 1
            let capturedPawnLocation = Location(to.file, captureRank)
            squares[squareIndex(location: from)] = nil
            squares[squareIndex(location: capturedPawnLocation)] = nil
            squares[squareIndex(location: to)] = Piece(player, .pawn)

        case .castleKingside(let player):
            switch player {
            case .white:
                squares[squareIndex(location: e1)] = nil
                squares[squareIndex(location: h1)] = nil
                squares[squareIndex(location: f1)] = WR
                squares[squareIndex(location: g1)] = WK

            case .black:
                squares[squareIndex(location: e8)] = nil
                squares[squareIndex(location: h8)] = nil
                squares[squareIndex(location: f8)] = BR
                squares[squareIndex(location: g8)] = BK
            }

        case .castleQueenside(let player):
            switch player {
            case .white:
                squares[squareIndex(location: e1)] = nil
                squares[squareIndex(location: a1)] = nil
                squares[squareIndex(location: d1)] = WR
                squares[squareIndex(location: c1)] = WK

            case .black:
                squares[squareIndex(location: e8)] = nil
                squares[squareIndex(location: a8)] = nil
                squares[squareIndex(location: d8)] = BR
                squares[squareIndex(location: c8)] = BK
            }

        case .resign:
            break
        }
    }

    /// Reverse the effect of the given `Move`, restoring the `Board` to its previous state.
    ///
    /// Results are undefined if the given move was not the last one applied to the board.
    public mutating func unapply(_ move: Move) {
        switch move {

        case .move(let piece, let from, let to):
            squares[squareIndex(location: from)] = piece
            squares[squareIndex(location: to)] = nil

        case .capture(let piece, let from, let to, let capturedKind):
            squares[squareIndex(location: from)] = piece
            squares[squareIndex(location: to)] = Piece(piece.player.opponent,
                                                       capturedKind)

        case .promote(let player, let from, let to, _):
            squares[squareIndex(location: from)] = Piece(player, .pawn)
            squares[squareIndex(location: to)] = nil

        case .promoteCapture(let player, let from, let to, let capturedKind, _):
            squares[squareIndex(location: from)] = Piece(player, .pawn)
            squares[squareIndex(location: to)] = Piece(player.opponent,
                                                       capturedKind)

        case .enPassantCapture(let player, let from, let to):
            let captureRank = (player == .white) ? to.rank - 1 : to.rank + 1
            let capturedPawnLocation = Location(to.file, captureRank)
            squares[squareIndex(location: from)] = Piece(player, .pawn)
            squares[squareIndex(location: capturedPawnLocation)] = Piece(player.opponent, .pawn)
            squares[squareIndex(location: to)] = nil

        case .castleKingside(let player):
            switch player {
            case .white:
                squares[squareIndex(location: e1)] = WK
                squares[squareIndex(location: h1)] = WR
                squares[squareIndex(location: f1)] = nil
                squares[squareIndex(location: g1)] = nil

            case .black:
                squares[squareIndex(location: e8)] = BK
                squares[squareIndex(location: h8)] = BR
                squares[squareIndex(location: f8)] = nil
                squares[squareIndex(location: g8)] = nil
            }

        case .castleQueenside(let player):
            switch player {
            case .white:
                squares[squareIndex(location: e1)] = WK
                squares[squareIndex(location: a1)] = WR
                squares[squareIndex(location: d1)] = nil
                squares[squareIndex(location: c1)] = nil

            case .black:
                squares[squareIndex(location: e8)] = BK
                squares[squareIndex(location: a8)] = BR
                squares[squareIndex(location: d8)] = nil
                squares[squareIndex(location: c8)] = nil
            }

        case .resign:
            break
        }
    }

    /// Return copy of board with the given `Piece` at the given `Location`.
    public func with(_ piece: Piece?, _ location: Location) -> Board {
        var newSquares = Array(squares)
        newSquares[squareIndex(location: location)] = piece

        return Board(newSquares)
    }

    /// Return copy of board with the given `Pieces` at the given `Locations`.
    public func with(_ pieceLocations: (Piece?, Location)...) -> Board {
        var newSquares = Array(squares)

        for (piece, location) in pieceLocations {
            newSquares[squareIndex(location: location)] = piece
        }

        return Board(newSquares)
    }

    /// Return array of (`Piece`, `Location`) tuples indicating pieces for the specified player.
    public func pieces(player: Player) -> [(Piece, Location)] {
        var result = [(Piece, Location)]()
        for squareIndex in 0..<squares.count {
            if let piece = squares[squareIndex], piece.player == player {
                result.append((piece, location(squareIndex: squareIndex)))
            }
        }
        return result
    }

    /// Return location of the given player's king, or nil if there is no king on the board.
    ///
    /// If there is more than one king of the given color, returns the first one found.
    public func kingLocation(player: Player) -> Location? {
        let king = Piece(player, .king)
        for squareIndex in 0..<squares.count {
            if let piece = squares[squareIndex], piece == king {
                return location(squareIndex: squareIndex)
            }
        }
        return nil
    }
}

// MARK:- Equatable
extension Board: Equatable {}
public func ==(lhs: Board, rhs: Board) -> Bool {
    if lhs.squares.count != rhs.squares.count {
        return false
    }

    for i in 0..<lhs.squares.count {
        if !(lhs.squares[i] == rhs.squares[i]) {
            return false
        }
    }

    return true
}
