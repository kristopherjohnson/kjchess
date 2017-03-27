//
//  Position_legalMoves.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

extension Position {

    /// Generate sequence of legal moves for this `Position`.
    ///
    public func legalMoves() -> AnySequence<Move> {
        guard let kingLocation = board.kingLocation(player: toMove) else {
            return possibleMoves()
        }

        return AnySequence(possibleMoves().filter {
            isLegal(move: $0, kingLocation: kingLocation)
        })
    }

    /// Generate array of possible moves for this `Position`.
    ///
    /// The generated moves will all be valid in the sense that
    /// the piece can perform the move/capture. However, this
    /// method does not verify that the move will not leave
    /// the player's king in check or that it doesn't result
    /// in a repeated board position.
    func possibleMoves() -> AnySequence<Move> {
        let pieces = board.pieces(player: toMove)
        return AnySequence(pieces.lazy.flatMap({ (piece, location) in
            return self.moves(piece: piece, location: location)
        }))
    }

    /// Generate array of moves for a `Piece` at the given `Location`.
    func moves(piece: Piece, location: Location) -> AnySequence<Move> {
        switch piece.kind {
        case .pawn:   return pawnMoves(piece: piece, location: location)
        case .knight: return knightMoves(piece: piece, location: location)
        case .rook:   return rookMoves(piece: piece, location: location)
        case .bishop: return bishopMoves(piece: piece, location: location)
        case .queen:  return queenMoves(piece: piece, location: location)
        case .king:   return kingMoves(piece: piece, location: location)
        }
    }

    func slideMoves(piece: Piece, location: Location, vectors: [(Int, Int)]) -> AnySequence<Move> {
        let player = piece.player
        var result = [Move]()

        for (h, v) in vectors {
            var file = location.file + h
            var rank = location.rank + v
            while let targetLocation = Location.ifValid(file: file, rank: rank) {
                if let occupant = board[targetLocation] {
                    if occupant.player != player {
                        result.append(.capture(piece: piece,
                                               from: location,
                                               to: targetLocation,
                                               captured: occupant.kind))
                    }
                    break
                }
                else {
                    result.append(.move(piece: piece, from: location, to: targetLocation))
                    file = file + h
                    rank = rank + v
                }
            }
        }

        return AnySequence(result)
    }

    // MARK:- Pawn

    static let whitePawnCaptureMoves = [(-1,  1), (1,  1)]
    static let blackPawnCaptureMoves = [(-1, -1), (1, -1)]

    static func pawnCaptureMoves(player: Player) -> [(Int, Int)] {
        switch player {
        case .white: return whitePawnCaptureMoves
        case .black: return blackPawnCaptureMoves
        }
    }

    static func pawnMoveDirection(player: Player) -> Int {
        switch player {
        case .white: return 1
        case .black: return -1
        }
    }

    static func pawnPromotionRank(player: Player) -> Int {
        switch player {
        case .white: return Board.maxRank
        case .black: return Board.minRank
        }
    }

    static func pawnStartRank(player: Player) -> Int {
        switch player {
        case .white: return Board.minRank + 1
        case .black: return Board.maxRank - 1
        }
    }

    func pawnMoves(piece: Piece, location: Location) -> AnySequence<Move> {
        let player = piece.player
        let file = location.file
        let rank = location.rank

        var result = [Move]()

        if Board.minRank < rank && rank < Board.maxRank {
            let moveDirection = Position.pawnMoveDirection(player: player)
            let nextRank = rank + moveDirection
            if board.isEmpty(file: file, rank: nextRank) {
                let to = Location(file, nextRank)

                let promotionRank = Position.pawnPromotionRank(player: player)
                if to.rank == promotionRank {
                    for kind in PieceKind.promotionKinds {
                        result.append(.promote(player: player,
                                               from: location,
                                               to: to,
                                               promoted: kind))
                    }
                }
                else {
                    result.append(.move(piece: piece, from: location, to: to))

                    let startRank = Position.pawnStartRank(player: player)
                    if rank == startRank {
                        let jumpRank = startRank + 2 * moveDirection
                        if board.isEmpty(file: file, rank: jumpRank) {
                            result.append(.move(piece: piece,
                                                from: location,
                                                to: Location(file, jumpRank)))
                        }
                    }
                }
            }

            let opponent = player.opponent
            let captureMoves = Position.pawnCaptureMoves(player: player)
            for (h, v) in captureMoves {
                if let captureLocation = Location.ifValid(file: file + h, rank: rank + v) {
                    if let occupant = board[captureLocation] {
                        if occupant.player == opponent {
                            result.append(.capture(piece: piece,
                                                   from: location,
                                                   to: captureLocation,
                                                   captured: occupant.kind))
                        }
                    }

                    // TODO: En-passant captures
                }
            }
        }

        return AnySequence(result)
    }

    // MARK:- Knight

    static let knightJumps = [
        ( 1, 2), ( 1, -2),
        (-1, 2), (-1, -2),
        ( 2, 1), ( 2, -1),
        (-2, 1), (-2, -1)
    ]

    func knightMoves(piece: Piece, location: Location) -> AnySequence<Move> {
        let file = location.file
        let rank = location.rank
        let player = piece.player

        var result = [Move]()

        for (h, v) in Position.knightJumps {
            if let targetLocation = Location.ifValid(file: file + h, rank: rank + v) {
                if let occupant = board[targetLocation] {
                    if occupant.player != player {
                        result.append(.capture(piece: piece,
                                               from: location,
                                               to: targetLocation,
                                               captured: occupant.kind))
                    }
                }
                else {
                    result.append(.move(piece: piece, from: location, to: targetLocation))
                }
            }
        }

        return AnySequence(result)
    }

    // MARK:- Rook

    static let rookVectors = [
        (1, 0), (-1,  0),
        (0, 1), ( 0, -1)
    ]

    func rookMoves(piece: Piece, location: Location) -> AnySequence<Move> {
        return slideMoves(piece: piece,
                          location: location,
                          vectors: Position.rookVectors)
    }

    // MARK:- Bishop

    static let bishopVectors = [
        (1,  1), (-1,  1),
        (1, -1), (-1, -1)
    ]

    func bishopMoves(piece: Piece, location: Location) -> AnySequence<Move> {
        return slideMoves(piece: piece,
                          location: location,
                          vectors: Position.bishopVectors)
    }

    // MARK:- Queen

    static let eightDirections = [
        (1,  0), (-1,  0),
        (0,  1), ( 0, -1),
        (1,  1), (-1,  1),
        (1, -1), (-1, -1)
    ]

    func queenMoves(piece: Piece, location: Location) -> AnySequence<Move> {
        return slideMoves(piece: piece,
                          location: location,
                          vectors: Position.eightDirections)
    }

    // MARK:- King

    func kingMoves(piece: Piece, location: Location) -> AnySequence<Move> {
        let file = location.file
        let rank = location.rank
        let player = piece.player

        var result = [Move]()

        for (h, v) in Position.eightDirections {
            if let targetLocation = Location.ifValid(file: file + h, rank: rank + v) {
                if let occupant = board[targetLocation] {
                    if occupant.player != player {
                        result.append(.capture(piece: piece,
                                               from: location,
                                               to: targetLocation,
                                               captured: occupant.kind))
                    }
                }
                else {
                    result.append(.move(piece: piece, from: location, to: targetLocation))
                }
            }
        }
        
        // TODO: Castling
        
        return AnySequence(result)
    }

    // MARK:- Legal moves

    /// Determine whether specified move is legal given the king's position.
    ///
    /// - todo: Optimize this. As-is, it generates a new position and checks all possible responses for any move that _might_ put the king into check.
    func isLegal(move: Move, kingLocation: Location) -> Bool {
        let from = move.from
        
        if from == kingLocation && !move.isResignation {
            let responses = possibleOpponentResponses(move: move)
            if responses.contains(where: { $0.isCapture && $0.to == move.to }) {
                return false
            }

            // TODO: For castling, need to check intervening squares as well.
        }
        else if from.isSameDiagonal(kingLocation) ||
            from.isSameFile(kingLocation) ||
            from.isSameRank(kingLocation)
        {
            let responses = possibleOpponentResponses(move: move)
            if responses.contains(where: { $0.isCapture && $0.to == kingLocation }) {
                return false
            }
        }
        
        return true
    }

    func possibleOpponentResponses(move: Move) -> AnySequence<Move> {
        return self.after(move).possibleMoves()
    }
}
