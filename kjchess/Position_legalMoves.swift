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

        let attackedLocations = Set(locationsUnderAttack(by: toMove.opponent))

        return AnySequence(possibleMoves().filter {
            isLegal(move: $0, kingLocation: kingLocation, attackedLocations: attackedLocations)
        })
    }

    /// Generate array of possible moves for this `Position`.
    ///
    /// The generated moves will all be valid in the sense that
    /// the piece can perform the move/capture. However, this
    /// method does not verify that the move will not leave
    /// the player's king in check or that it doesn't result
    /// in a repeated board position.
    private func possibleMoves() -> AnySequence<Move> {
        let pieces = board.pieces(player: toMove)
        return AnySequence(pieces.lazy.flatMap({ (piece, location) in
            return self.moves(piece: piece, location: location)
        }))
    }

    /// Generate array of locations under attack by the player who is not moving.
    private func locationsUnderAttack(by player: Player) -> AnySequence<Location> {
        let pieces = board.pieces(player: player)
        let moves = pieces.lazy.flatMap({ (piece, location) in
            return self.moves(piece: piece, location: location)
        })

        // Determine whether specified move is attacking its destination.
        //
        // Returns `true` for all moves except pawn non-capture moves.
        func isAttackingDestination(_ move: Move) -> Bool {
            switch move {
            case .move(let piece, _, _):
                if piece.kind == .pawn {
                    return false
                }
            default: break
            }

            return true
        }

        return AnySequence(moves.filter { isAttackingDestination($0) }.map { $0.to })
    }

    /// Generate array of moves for a `Piece` at the given `Location`.
    private func moves(piece: Piece, location: Location) -> AnySequence<Move> {
        switch piece.kind {
        case .pawn:   return pawnMoves(piece: piece, location: location)
        case .knight: return knightMoves(piece: piece, location: location)
        case .rook:   return rookMoves(piece: piece, location: location)
        case .bishop: return bishopMoves(piece: piece, location: location)
        case .queen:  return queenMoves(piece: piece, location: location)
        case .king:   return kingMoves(piece: piece, location: location)
        }
    }

    private func slideMoves(piece: Piece, location: Location, vectors: [(Int, Int)]) -> AnySequence<Move> {
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

    private static let whitePawnCaptureMoves = [(-1,  1), (1,  1)]
    private static let blackPawnCaptureMoves = [(-1, -1), (1, -1)]

    private static func pawnCaptureMoves(player: Player) -> [(Int, Int)] {
        switch player {
        case .white: return whitePawnCaptureMoves
        case .black: return blackPawnCaptureMoves
        }
    }

    private static func pawnMoveDirection(player: Player) -> Int {
        switch player {
        case .white: return 1
        case .black: return -1
        }
    }

    private static func pawnPromotionRank(player: Player) -> Int {
        switch player {
        case .white: return Board.maxRank
        case .black: return Board.minRank
        }
    }

    private static func pawnStartRank(player: Player) -> Int {
        switch player {
        case .white: return Board.minRank + 1
        case .black: return Board.maxRank - 1
        }
    }

    private func pawnMoves(piece: Piece, location: Location) -> AnySequence<Move> {
        let player = piece.player
        let file = location.file
        let rank = location.rank

        var result = [Move]()

        if Board.minRank < rank && rank < Board.maxRank {
            let promotionRank = Position.pawnPromotionRank(player: player)
            let moveDirection = Position.pawnMoveDirection(player: player)
            let nextRank = rank + moveDirection
            if board.isEmpty(file: file, rank: nextRank) {
                let to = Location(file, nextRank)

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
                            if captureLocation.rank == promotionRank {
                                for kind in PieceKind.promotionKinds {
                                    result.append(.promoteCapture(player: player,
                                                                  from: location,
                                                                  to: captureLocation,
                                                                  captured: occupant.kind,
                                                                  promoted: kind))
                                }
                            }
                            else {
                                result.append(.capture(piece: piece,
                                                       from: location,
                                                       to: captureLocation,
                                                       captured: occupant.kind))
                            }
                        }
                    }
                    else if let enPassantCaptureLocation = enPassantCaptureLocation,
                        captureLocation == enPassantCaptureLocation {
                        result.append(.enPassantCapture(player: player,
                                                        from: location,
                                                        to: enPassantCaptureLocation))
                    }
                }
            }
        }

        return AnySequence(result)
    }

    // MARK:- Knight

    private static let knightJumps = [
        ( 1, 2), ( 1, -2),
        (-1, 2), (-1, -2),
        ( 2, 1), ( 2, -1),
        (-2, 1), (-2, -1)
    ]

    private func knightMoves(piece: Piece, location: Location) -> AnySequence<Move> {
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

    private static let rookVectors = [
        (1, 0), (-1,  0),
        (0, 1), ( 0, -1)
    ]

    private func rookMoves(piece: Piece, location: Location) -> AnySequence<Move> {
        return slideMoves(piece: piece,
                          location: location,
                          vectors: Position.rookVectors)
    }

    // MARK:- Bishop

    private static let bishopVectors = [
        (1,  1), (-1,  1),
        (1, -1), (-1, -1)
    ]

    private func bishopMoves(piece: Piece, location: Location) -> AnySequence<Move> {
        return slideMoves(piece: piece,
                          location: location,
                          vectors: Position.bishopVectors)
    }

    // MARK:- Queen

    private static let eightDirections = [
        (1,  0), (-1,  0),
        (0,  1), ( 0, -1),
        (1,  1), (-1,  1),
        (1, -1), (-1, -1)
    ]

    private func queenMoves(piece: Piece, location: Location) -> AnySequence<Move> {
        return slideMoves(piece: piece,
                          location: location,
                          vectors: Position.eightDirections)
    }

    // MARK:- King

    private func kingMoves(piece: Piece, location: Location) -> AnySequence<Move> {
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
        
        switch player {
        case .white:
            if whiteCanCastleKingside &&
                board[e1] == WK &&
                board[f1] == nil &&
                board[g1] == nil &&
                board[h1] == WR
            {
                result.append(.castleKingside(player: player))
            }

            if whiteCanCastleQueenside &&
                board[e1] == WK &&
                board[d1] == nil &&
                board[c1] == nil &&
                board[b1] == nil &&
                board[a1] == WR
            {
                result.append(.castleQueenside(player: player))
            }

        case .black:
            if blackCanCastleKingside &&
                board[e8] == BK &&
                board[f8] == nil &&
                board[g8] == nil &&
                board[h8] == BR
            {
                result.append(.castleKingside(player: player))
            }

            if blackCanCastleQueenside &&
                board[e8] == BK &&
                board[d8] == nil &&
                board[c8] == nil &&
                board[b8] == nil &&
                board[a8] == BR
            {
                result.append(.castleQueenside(player: player))
            }
        }
        
        return AnySequence(result)
    }

    // MARK:- Legal moves

    /// Determine whether specified move is legal given the king's position.
    ///
    /// - todo: Optimize this. As-is, it generates a new position and checks all possible responses for any move that _might_ put the king into check.
    private func isLegal(move: Move, kingLocation: Location, attackedLocations: Set<Location>) -> Bool {
        let from = move.from

        let responses = possibleOpponentResponses(move: move)

        // If King moving, ensure it doesn't move into check.
        if from == kingLocation && !move.isResignation {
            if responses.contains(where: { $0.isCapture && $0.to == move.to }) {
                return false
            }

            // If castling, can't be in check or move through attacked squares
            switch move {
            case .castleKingside(.white):
                if attackedLocations.contains(kingLocation) ||
                    attackedLocations.contains(f1)
                {
                    return false
                }
            case .castleQueenside(.white):
                if attackedLocations.contains(kingLocation) ||
                    attackedLocations.contains(d1)
                {
                    return false
                }
            case .castleKingside(.black):
                if attackedLocations.contains(kingLocation) ||
                    attackedLocations.contains(f8)
                {
                    return false
                }
            case .castleQueenside(.black):
                if attackedLocations.contains(kingLocation) ||
                    attackedLocations.contains(d8)
                {
                    return false
                }
            default:
                break
            }
        }

        // Otherwise, ensure King is not left in check
        else if responses.contains(where: { $0.isCapture && $0.to == kingLocation }) {
            return false
        }
        
        return true
    }

    /// Get the moves that the opponent can make after the specified move is made.
    private func possibleOpponentResponses(move: Move) -> AnySequence<Move> {
        return self.after(move).possibleMoves()
    }
}
