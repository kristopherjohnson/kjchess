//
//  Position_generateMoves.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

extension Position {
    /// Generate array of legal moves for this `Position`.
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
            if rank < Board.lastRank {
                if board.isEmpty(file: file, rank: rank + 1) {
                    let to = Location(file, rank + 1)
                    if to.rank == Board.lastRank {
                        for kind in PieceKind.promotionKinds {
                            result.append(.promote(player: player,
                                                   from: location,
                                                   to: to,
                                                   promotedPiece: Piece(player, kind)))
                        }
                    }
                    else {
                        result.append(.move(piece: piece, from: location, to: to))
                    }
                }
            }

        case .black:
            if rank > 0 {
                if board.isEmpty(file: file, rank: rank - 1) {
                    let to = Location(file, rank - 1)
                    if to.rank == Board.firstRank {
                        for kind in PieceKind.promotionKinds {
                            result.append(.promote(player: player,
                                                   from: location,
                                                   to: to,
                                                   promotedPiece: Piece(player, kind)))
                        }
                    }
                    else {
                        result.append(.move(piece: piece, from: location, to: to))
                    }
                }
            }
        }
        
        return AnySequence(result)
    }
}
