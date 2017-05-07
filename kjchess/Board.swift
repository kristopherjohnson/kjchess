//
//  Board.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

/// Chess board.
///
/// Representation is an 8x8 array where each
/// element may be a `Piece` or be empty (`nil`).
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
        = Board(Array(repeating: xx, count: Board.squaresCount))

    public static let newGame
        = Board([WR,  WN,  WB,  WQ,  WK,  WB,  WN,  WR,
                 WP,  WP,  WP,  WP,  WP,  WP,  WP,  WP,
                 xx,  xx,  xx,  xx,  xx,  xx,  xx,  xx, 
                 xx,  xx,  xx,  xx,  xx,  xx,  xx,  xx, 
                 xx,  xx,  xx,  xx,  xx,  xx,  xx,  xx, 
                 xx,  xx,  xx,  xx,  xx,  xx,  xx,  xx, 
                 BP,  BP,  BP,  BP,  BP,  BP,  BP,  BP,
                 BR,  BN,  BB,  BQ,  BK,  BB,  BN,  BR])

    /// The arrays that hold the board state.
    ///
    /// Each array has 64 elements.  The first 8 are for squares
    /// a1-a8, the next 8 are for b1-b8, and so on.
    ///
    /// The arrays are not marked `public` or `private`.  They
    /// should be treated as `private` to the `Board` type and
    /// its extensions, but Swift 3 doesn't provide that kind of
    /// access control specification.

    var player: [Player]
    var kind: [PieceKind]

    public init(_ squares: [Piece]) {
        assert(squares.count == Board.squaresCount,
               "Number of squares must be 64")
        self.player = squares.map { $0.player }
        self.kind = squares.map { $0.kind }
    }

    public init(_ playerArray: [Player], _ kindArray: [PieceKind]) {
        assert(playerArray.count == Board.squaresCount,
               "Number of Player elements must be 64")
        assert(kindArray.count == Board.squaresCount,
               "Number of PieceKind elements must be 64")
        self.player = playerArray
        self.kind = kindArray
    }

    /// Return `Piece` at the specified `Location`.
    public private(set) subscript(location: Location) -> Piece {
        get {
            let index = location.squareIndex
            return Piece(player[index], kind[index])
        }
        set {
            let index = location.squareIndex
            player[index] = newValue.player
            kind[index] = newValue.kind
        }
    }

    private(set) subscript(squareIndex: Int) -> Piece {
        get {
            return Piece(player[squareIndex], kind[squareIndex])
        }
        set {
            player[squareIndex] = newValue.player
            kind[squareIndex] = newValue.kind
        }
    }

    /// Return `Piece` at the specified location.
    public func at(file: Int, rank: Int) -> Piece {
        let index = rank * Board.filesCount + file
        return Piece(player[index], kind[index])
    }

    /// Return `Piece` at the specified location if it is not empty.
    public func pieceAt(file: Int, rank: Int) -> Piece? {
        let piece = at(file: file, rank: rank)
        return piece.isEmpty ? nil : piece
    }

    /// Return `true` if specified `Location` has no piece on it.
    public func isEmpty(_ location: Location) -> Bool {
        return player[location.squareIndex] == .empty
    }

    /// Return `true` if specified square has no piece on it.
    public func isEmpty(file: Int, rank: Int) -> Bool {
        return at(file: file, rank: rank).isEmpty
    }

    /// Return copy of board after applying the given `Move`.
    ///
    /// This method does not validate whether the move is valid
    /// of the specified pieces exist.
    public func after(_ move: Move) -> Board {
        var newBoard = self
        newBoard.apply(move)
        return newBoard
    }

    /// Applying the given `Move` to the `Board`, modifying it.
    ///
    /// This method does not validate whether the move is valid
    /// of the specified pieces exist.
    public mutating func apply(_ move: Move) {
        switch move {

        case .move(let piece, let from, let to),
             .capture(let piece, let from, let to, _):
            self[from] = xx
            self[to] = piece

        case .promote(let player, let from, let to, let promoted),
             .promoteCapture(let player, let from, let to, _, let promoted):
            self[from] = xx
            self[to] = Piece(player, promoted)

        case .enPassantCapture(let player, let from, let to):
            let captureRank = (player == .white) ? to.rank - 1 : to.rank + 1
            let capturedPawnLocation = Location(to.file, captureRank)
            self[from] = xx
            self[capturedPawnLocation] = xx
            self[to] = Piece(player, .pawn)

        case .castleKingside(let player):
            switch player {
            case .white:
                self[e1] = xx
                self[h1] = xx
                self[f1] = WR
                self[g1] = WK

            case .black:
                self[e8] = xx
                self[h8] = xx
                self[f8] = BR
                self[g8] = BK

            case .empty:
                assert(false)
            }


        case .castleQueenside(let player):
            switch player {
            case .white:
                self[e1] = xx
                self[a1] = xx
                self[d1] = WR
                self[c1] = WK

            case .black:
                self[e8] = xx
                self[a8] = xx
                self[d8] = BR
                self[c8] = BK

            case .empty:
                assert(false)
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
            self[from] = piece
            self[to] = xx

        case .capture(let piece, let from, let to, let capturedKind):
            self[from] = piece
            self[to] = Piece(piece.player.opponent, capturedKind)

        case .promote(let player, let from, let to, _):
            self[from] = Piece(player, .pawn)
            self[to] = xx

        case .promoteCapture(let player, let from, let to, let capturedKind, _):
            self[from] = Piece(player, .pawn)
            self[to] = Piece(player.opponent, capturedKind)

        case .enPassantCapture(let player, let from, let to):
            let captureRank = (player == .white) ? to.rank - 1 : to.rank + 1
            let capturedPawnLocation = Location(to.file, captureRank)
            self[from] = Piece(player, .pawn)
            self[capturedPawnLocation] = Piece(player.opponent, .pawn)
            self[to] = xx

        case .castleKingside(let player):
            switch player {
            case .white:
                self[e1] = WK
                self[h1] = WR
                self[f1] = xx
                self[g1] = xx

            case .black:
                self[e8] = BK
                self[h8] = BR
                self[f8] = xx
                self[g8] = xx

            case .empty:
                assert(false)
            }

        case .castleQueenside(let player):
            switch player {
            case .white:
                self[e1] = WK
                self[a1] = WR
                self[d1] = xx
                self[c1] = xx

            case .black:
                self[e8] = BK
                self[a8] = BR
                self[d8] = xx
                self[c8] = xx

            case .empty:
                assert(false)
            }

        case .resign:
            break
        }
    }

    /// Return copy of board with the given `Piece` at the given `Location`.
    public func with(_ piece: Piece, _ location: Location) -> Board {
        var newPlayer = Array(player)
        var newKind = Array(kind)

        newPlayer[location.squareIndex] = piece.player
        newKind[location.squareIndex] = piece.kind

        return Board(newPlayer, newKind)
    }

    /// Return copy of board with the given `Pieces` at the given `Locations`.
    public func with(_ pieceLocations: (Piece, Location)...) -> Board {
        var newPlayer = Array(player)
        var newKind = Array(kind)

        for (piece, location) in pieceLocations {
            newPlayer[location.squareIndex] = piece.player
            newKind[location.squareIndex] = piece.kind
        }

        return Board(newPlayer, newKind)
    }

    /// Return array of (`Piece`, `Location`) tuples indicating pieces for the specified player.
    public func pieces(player p: Player) -> [(Piece, Location)] {
        var result = [(Piece, Location)]()
        result.reserveCapacity(16)
        for squareIndex in 0..<Board.squaresCount {
            if player[squareIndex] == p {
                let piece = Piece(p, kind[squareIndex])
                result.append((piece, Location(squareIndex: squareIndex)))
            }
        }
        return result
    }

    /// Return location of the given player's king, or nil if there is no king on the board.
    ///
    /// If there is more than one king of the given color, returns the first one found.
    public func kingLocation(player p: Player) -> Location? {
        for squareIndex in 0..<Board.squaresCount {
            if kind[squareIndex] == .king  && player[squareIndex] == p {
                return Location(squareIndex: squareIndex)
            }
        }
        return nil
    }
}

// MARK:- Equatable
extension Board: Equatable {}
public func ==(lhs: Board, rhs: Board) -> Bool {
    for i in 0..<Board.squaresCount {
        if !(lhs.kind[i] == rhs.kind[i] && lhs.player[i] == rhs.player[i]) {
            return false
        }
    }

    return true
}
