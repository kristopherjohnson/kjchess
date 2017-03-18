//
//  Position_generateMoves.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

extension Position {
    /// Generate array of legal moves for this `Position`.
    ///
    /// The generated moves will all be valid in the sense that
    /// the piece can perform the move/capture. However, this
    /// method does not verify that the move will not leave
    /// the player's king in check or that it doesn't result
    /// in a repeated board position.
    public func generateMoves() -> AnySequence<Move> {
        let pieces = board.pieces(player: toMove)
        return AnySequence(pieces.lazy.flatMap({ (piece, location) in
            return self.generateMoves(piece: piece, location: location)
        }))
    }

    /// Generate array of legal moves for a `Piece` at the given `Location`.
    public func generateMoves(piece: Piece, location: Location) -> AnySequence<Move> {
        switch piece.kind {
        case .pawn: return generatePawnMoves(player: piece.player, location: location)
        case .knight: return generateKnightMoves(player: piece.player, location: location)
        default:
            // TODO
            return AnySequence([])
        }
    }

    func generatePawnMoves(player: Player, location: Location) -> AnySequence<Move> {
        let file = location.file
        let rank = location.rank
        let piece = Piece(player, .pawn)

        var result = [Move]()
        switch player {

        case .white:
            if rank < Board.maxRank {
                if board.isEmpty(file: file, rank: rank + 1) {
                    let to = Location(file, rank + 1)
                    if to.rank == Board.maxRank {
                        for kind in PieceKind.promotionKinds {
                            result.append(.promote(player: player,
                                                   from: location,
                                                   to: to,
                                                   promotedPiece: Piece(player, kind)))
                        }
                    }
                    else {
                        result.append(.move(piece: piece, from: location, to: to))
                        if rank == 1 && board.isEmpty(file: file, rank: 3) {
                            result.append(.move(piece: piece, from: location, to: Location(file, 3)))
                        }
                    }
                }
            }

        case .black:
            if rank > 0 {
                if board.isEmpty(file: file, rank: rank - 1) {
                    let to = Location(file, rank - 1)
                    if to.rank == Board.minRank {
                        for kind in PieceKind.promotionKinds {
                            result.append(.promote(player: player,
                                                   from: location,
                                                   to: to,
                                                   promotedPiece: Piece(player, kind)))
                        }
                    }
                    else {
                        result.append(.move(piece: piece, from: location, to: to))
                        if rank == 6 && board.isEmpty(file: file, rank: 4) {
                            result.append(.move(piece: piece, from: location, to: Location(file, 4)))
                        }
                    }
                }
            }
        }
        
        return AnySequence(result)
    }

    static let knightJumps = [
        ( 1, 2), ( 1, -2),
        (-1, 2), (-1, -2),
        ( 2, 1), ( 2, -1),
        (-2, 1), (-2, -1)
    ]

    func generateKnightMoves(player: Player, location: Location) -> AnySequence<Move> {
        let file = location.file
        let rank = location.rank
        let piece = Piece(player, .knight)

        var result = [Move]()

        for (h, v) in Position.knightJumps {
            if let targetLocation = Location.ifValid(file: file + h, rank: rank + v) {
                if let occupant = board[targetLocation] {
                    if occupant.player != player {
                        result.append(.capture(piece: piece,
                                               from: location,
                                               to: targetLocation,
                                               capturedPiece: occupant))
                    }
                }
                else {
                    result.append(.move(piece: piece, from: location, to: targetLocation))
                }
            }
        }

        return AnySequence(result)
    }
}
