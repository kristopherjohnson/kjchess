//
//  Position_legalMovesTests.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import XCTest
import kjchess

class Position_legalMovesTests: XCTestCase {

    func testWhiteNewGameMoves() {
        let pos = Position.newGame()

        let expectedMoves = [
           "WPa2-a3", "WPa2-a4",
           "WPb2-b3", "WPb2-b4",
           "WPc2-c3", "WPc2-c4",
           "WPd2-d3", "WPd2-d4",
           "WPe2-e3", "WPe2-e4",
           "WPf2-f3", "WPf2-f4",
           "WPg2-g3", "WPg2-g4",
           "WPh2-h3", "WPh2-h4",
           "WNb1-a3", "WNb1-c3",
           "WNg1-f3", "WNg1-h3"
        ]

        let moves = pos.legalMoves()

        XCTAssertEqual(moves.count, expectedMoves.count)

        for expectedMove in expectedMoves {
            XCTAssertTrue(moves.contains { $0.description == expectedMove },
                          "Expected \(expectedMove), but it's missing")
        }
    }

    func testBlackNewGameMoves() {
        let board = Board.newGame.with((WP,  e4),
                                       (nil, e2))

        let pos = Position(board: board, toMove: .black, moves: [])

        let expectedMoves = [
           "BPa7-a6", "BPa7-a5",
           "BPb7-b6", "BPb7-b5",
           "BPc7-c6", "BPc7-c5",
           "BPd7-d6", "BPd7-d5",
           "BPe7-e6", "BPe7-e5",
           "BPf7-f6", "BPf7-f5",
           "BPg7-g6", "BPg7-g5",
           "BPh7-h6", "BPh7-h5",
           "BNb8-a6", "BNb8-c6",
           "BNg8-f6", "BNg8-h6"
        ]

        let moves = pos.legalMoves()

        XCTAssertEqual(moves.count, expectedMoves.count)

        for expectedMove in expectedMoves {
            XCTAssertTrue(moves.contains { $0.description == expectedMove },
                          "Expected \(expectedMove), but it's missing")
        }

        for move in moves {
            XCTAssertFalse(move.isCapture,
                           "Should not be a capturing move")
        }
    }

    func testWhitePawnCaptures() {
        let board = Board.empty.with((WP, e4),
                                     (BB, d5),
                                     (BP, e5),
                                     (BN, f5))

        let pos = Position(board: board, toMove: .white, moves: [])

        let expectedMoves = [
            "WPe4xBd5",
            "WPe4xNf5"
        ]

        let moves = pos.legalMoves()

        XCTAssertEqual(moves.count, expectedMoves.count)

        for expectedMove in expectedMoves {
            XCTAssertTrue(moves.contains { $0.description == expectedMove },
                          "Expected \(expectedMove), but it's missing")
        }
    }

    func testBlackPawnCaptures() {
        let board = Board.empty.with((BP, d5),
                                     (WB, c4),
                                     (WP, d4),
                                     (WN, e4))

        let pos = Position(board: board, toMove: .black, moves: [])

        let expectedMoves = [
            "BPd5xBc4",
            "BPd5xNe4"
        ]

        let moves = pos.legalMoves()

        XCTAssertEqual(moves.count, expectedMoves.count)

        for expectedMove in expectedMoves {
            XCTAssertTrue(moves.contains { $0.description == expectedMove },
                          "Expected \(expectedMove), but it's missing")
        }
    }
    
    func testKnightMovesEmptyBoard() {
        let board = Board.empty.with(WN, d4)

        let pos = Position(board: board, toMove: .white, moves: [])

        let expectedMoves = [
           "WNd4-c6",
           "WNd4-e6",
           "WNd4-f5",
           "WNd4-f3",
           "WNd4-e2",
           "WNd4-c2",
           "WNd4-b3",
           "WNd4-b5"
        ]

        let moves = pos.legalMoves()

        XCTAssertEqual(moves.count, expectedMoves.count)

        for expectedMove in expectedMoves {
            XCTAssertTrue(moves.contains { $0.description == expectedMove },
                          "Expected \(expectedMove), but it's missing")
        }
    }

    func testKnightMovesAllBlocked() {
        // Knight at d4 with pawns at all locations it could jump to.
        let board = Board.empty.with((WN, d4),
                                     (WP, c6),
                                     (WP, e6),
                                     (WP, f5),
                                     (WP, f3),
                                     (WP, e2),
                                     (WP, c2),
                                     (WP, b3),
                                     (WP, b5))

        let pos = Position(board: board, toMove: .white, moves: [])

        // Note: Filter out the moves that the pawns could make.
        let moves = pos.legalMoves().filter { $0.from == d4 }

        XCTAssertEqual(0, moves.count,
                       "No moves by the knight are possible")
    }

    func testKnightCaptures() {
        // White knight at d4 with black queens at every location can jump to
        let board = Board.empty.with((WN, d4),
                                     (BQ, c6),
                                     (BQ, e6),
                                     (BQ, f5),
                                     (BQ, f3),
                                     (BQ, e2),
                                     (BQ, c2),
                                     (BQ, b3),
                                     (BQ, b5))

        let pos = Position(board: board, toMove: .white, moves: [])

        let expectedMoves = [
           "WNd4xQc6",
           "WNd4xQe6",
           "WNd4xQf5",
           "WNd4xQf3",
           "WNd4xQe2",
           "WNd4xQc2",
           "WNd4xQb3",
           "WNd4xQb5"
        ]

        let moves = pos.legalMoves()

        XCTAssertEqual(moves.count, expectedMoves.count)

        for expectedMove in expectedMoves {
            XCTAssertTrue(moves.contains { $0.description == expectedMove },
                          "Expected \(expectedMove), but it's missing")
        }
    }

    func testRookMovesEmptyBoard() {
        let board = Board.empty.with(WR, d4)

        let pos = Position(board: board, toMove: .white, moves: [])

        let expectedMoves = [
           "WRd4-d1",
           "WRd4-d2",
           "WRd4-d3",
           "WRd4-d5",
           "WRd4-d6",
           "WRd4-d7",
           "WRd4-d8",
           "WRd4-a4",
           "WRd4-b4",
           "WRd4-c4",
           "WRd4-e4",
           "WRd4-f4",
           "WRd4-g4",
           "WRd4-h4"
        ]

        let moves = pos.legalMoves()

        XCTAssertEqual(moves.count, expectedMoves.count)

        for expectedMove in expectedMoves {
            XCTAssertTrue(moves.contains { $0.description == expectedMove },
                          "Expected \(expectedMove), but it's missing")
        }
    }

    func testRookCaptures() {
        let board = Board.empty.with((WR, d4),
                                     (BQ, d1),
                                     (BQ, d2),
                                     (BQ, d7),
                                     (BQ, d8),
                                     (BQ, a4),
                                     (BQ, b4),
                                     (BQ, g4),
                                     (BQ, h4))

        let pos = Position(board: board, toMove: .white, moves: [])

        let expectedMoves = [
            "WRd4xQd2",
            "WRd4-d3",
            "WRd4-d5",
            "WRd4-d6",
            "WRd4xQd7",
            "WRd4xQb4",
            "WRd4-c4",
            "WRd4-e4",
            "WRd4-f4",
            "WRd4xQg4"
        ]

        let moves = pos.legalMoves()

        XCTAssertEqual(moves.count, expectedMoves.count)

        for expectedMove in expectedMoves {
            XCTAssertTrue(moves.contains { $0.description == expectedMove },
                          "Expected \(expectedMove), but it's missing")
        }
    }

    func testBishopMovesEmptyBoard() {
        let board = Board.empty.with(WB, e4)

        let pos = Position(board: board, toMove: .white, moves: [])

        let expectedMoves = [
            "WBe4-a8",
            "WBe4-b7",
            "WBe4-c6",
            "WBe4-d5",
            "WBe4-f3",
            "WBe4-g2",
            "WBe4-h1",
            "WBe4-b1",
            "WBe4-c2",
            "WBe4-d3",
            "WBe4-f5",
            "WBe4-g6",
            "WBe4-h7"
        ]

        let moves = pos.legalMoves()

        XCTAssertEqual(moves.count, expectedMoves.count)

        for expectedMove in expectedMoves {
            XCTAssertTrue(moves.contains { $0.description == expectedMove },
                          "Expected \(expectedMove), but it's missing")
        }
    }

    func testBishopCaptures() {
        let board = Board.empty.with((BB, d4),
                                     (WQ, b6),
                                     (WQ, a7),
                                     (WQ, g7),
                                     (WQ, h8),
                                     (WQ, a1),
                                     (WQ, b2),
                                     (WQ, f2),
                                     (WQ, g1))

        let pos = Position(board: board, toMove: .black, moves: [])

        let expectedMoves = [
            "BBd4-c3",
            "BBd4xQb2",
            "BBd4-c5",
            "BBd4xQb6",
            "BBd4-e5",
            "BBd4-f6",
            "BBd4xQg7",
            "BBd4-e3",
            "BBd4xQf2"
        ]

        let moves = pos.legalMoves()

        XCTAssertEqual(moves.count, expectedMoves.count)

        for expectedMove in expectedMoves {
            XCTAssertTrue(moves.contains { $0.description == expectedMove },
                          "Expected \(expectedMove), but it's missing")
        }
    }

    func testQueenEmptyBoard() {
        let board = Board.empty.with(BQ, c3)

        let pos = Position(board: board, toMove: .black, moves: [])

        let expectedMoves = [
            "BQc3-a1",
            "BQc3-b2",
            "BQc3-d4",
            "BQc3-e5",
            "BQc3-f6",
            "BQc3-g7",
            "BQc3-h8",
            "BQc3-a5",
            "BQc3-b4",
            "BQc3-d2",
            "BQc3-e1",
            "BQc3-a3",
            "BQc3-b3",
            "BQc3-d3",
            "BQc3-e3",
            "BQc3-f3",
            "BQc3-g3",
            "BQc3-h3",
            "BQc3-c1",
            "BQc3-c2",
            "BQc3-c4",
            "BQc3-c5",
            "BQc3-c6",
            "BQc3-c7",
            "BQc3-c8"
        ]

        let moves = pos.legalMoves()

        XCTAssertEqual(moves.count, expectedMoves.count)

        for expectedMove in expectedMoves {
            XCTAssertTrue(moves.contains { $0.description == expectedMove },
                          "Expected \(expectedMove), but it's missing")
        }
    }

    func testQueenCaptures() {
        let board = Board.empty.with((BQ, d4),
                                     (WQ, b6),
                                     (WQ, a7),
                                     (WQ, g7),
                                     (WQ, h8),
                                     (WQ, a1),
                                     (WQ, b2),
                                     (WQ, f2),
                                     (WQ, g1),
                                     (WQ, f4),
                                     (WQ, b4),
                                     (WQ, d2),
                                     (WQ, d6))

        let pos = Position(board: board, toMove: .black, moves: [])

        let expectedMoves = [
            "BQd4-c3",
            "BQd4xQb2",
            "BQd4-c5",
            "BQd4xQb6",
            "BQd4-e5",
            "BQd4-f6",
            "BQd4xQg7",
            "BQd4-e3",
            "BQd4xQf2",
            "BQd4-c4",
            "BQd4xQb4",
            "BQd4-e4",
            "BQd4xQf4",
            "BQd4-d3",
            "BQd4xQd2",
            "BQd4-d5",
            "BQd4xQd6"
        ]

        let moves = pos.legalMoves()

        XCTAssertEqual(moves.count, expectedMoves.count)

        for expectedMove in expectedMoves {
            XCTAssertTrue(moves.contains { $0.description == expectedMove },
                          "Expected \(expectedMove), but it's missing")
        }
    }

    func testKingEmptyBoard() {
        let board = Board.empty.with(WK, e3)

        let pos = Position(board: board, toMove: .white, moves: [])

        let expectedMoves = [
            "WKe3-e4",
            "WKe3-f4",
            "WKe3-f3",
            "WKe3-f2",
            "WKe3-e2",
            "WKe3-d2",
            "WKe3-d3",
            "WKe3-d4"
        ]

        let moves = pos.legalMoves()

        XCTAssertEqual(moves.count, expectedMoves.count)

        for expectedMove in expectedMoves {
            XCTAssertTrue(moves.contains { $0.description == expectedMove },
                          "Expected \(expectedMove), but it's missing")
        }
    }

    func testKingCaptures() {
        let board = Board.empty.with((WK, d4),
                                     (BP, c3),
                                     (BP, d3),
                                     (BP, e3))
        let pos = Position(board: board, toMove: .white, moves: [])

        let expectedMoves = [
            "WKd4-d5",
            "WKd4-e5",
            "WKd4-e4",
            "WKd4xPe3",
            "WKd4xPd3",
            "WKd4xPc3",
            "WKd4-c4",
            "WKd4-c5"
        ]

        let moves = pos.legalMoves()

        XCTAssertEqual(moves.count, expectedMoves.count)

        for expectedMove in expectedMoves {
            XCTAssertTrue(moves.contains { $0.description == expectedMove },
                          "Expected \(expectedMove), but it's missing")
        }
    }

    func testLegalMovesPawnPinnedByQueen() {
        // Note: WP at b2 is pinned by BQ at h8.
        let board = Board.empty.with((WK, a1),
                                     (WP, a2),
                                     (WP, b2),
                                     (BQ, h8))

        let pos = Position(board: board, toMove: .white, moves: [])

        let expectedMoves = [
            "WPa2-a3",
            "WPa2-a4",
            "WKa1-b1"
            // WPb2-b3 and WPb2-b4 are not legal
        ]

        let moves = pos.legalMoves()

        XCTAssertEqual(moves.count, expectedMoves.count)

        for expectedMove in expectedMoves {
            XCTAssertTrue(moves.contains { $0.description == expectedMove },
                          "Expected \(expectedMove), but it's missing")
        }
    }

    func testLegalMovesKnightPinnedByBishop() {
        // Note: BN at g7 is pinned by WB at a1.
        let board = Board.empty.with((BK, h8),
                                     (BN, g7),
                                     (BP, h7),
                                     (WB, a1))

        let pos = Position(board: board, toMove: .black, moves: [])

        let expectedMoves = [
            "BPh7-h6",
            "BPh7-h5",
            "BKh8-g8"
            // BN cannot move
        ]

        let moves = pos.legalMoves()

        XCTAssertEqual(moves.count, expectedMoves.count)

        for expectedMove in expectedMoves {
            XCTAssertTrue(moves.contains { $0.description == expectedMove },
                          "Expected \(expectedMove), but it's missing")
        }
    }

    func testLegalMovesBishopPinnedByQueen() {
        // Note: WB at e1 is pinned by BQ at e8.
        let board = Board.empty.with((WK, e1),
                                     (WB, e2),
                                     (BQ, e8))

        let pos = Position(board: board, toMove: .white, moves: [])

        let expectedMoves = [
            "WKe1-d1",
            "WKe1-d2",
            "WKe1-f1",
            "WKe1-f2"
            // bishop cannot move
        ]

        let moves = pos.legalMoves()

        XCTAssertEqual(moves.count, expectedMoves.count)

        for expectedMove in expectedMoves {
            XCTAssertTrue(moves.contains { $0.description == expectedMove },
                          "Expected \(expectedMove), but it's missing")
        }
    }

    func testLegalMovesBishopPinnedByRook() {
        // Note: BB at g5 is pinned by WR at a5.
        let board = Board.empty.with((BK, h5),
                                     (BB, g5),
                                     (WR, a5))

        let pos = Position(board: board, toMove: .black, moves: [])

        let expectedMoves = [
            "BKh5-h6",
            "BKh5-g6",
            "BKh5-h4",
            "BKh5-g4"
            // bishop cannot move
        ]

        let moves = pos.legalMoves()

        XCTAssertEqual(moves.count, expectedMoves.count)

        for expectedMove in expectedMoves {
            XCTAssertTrue(moves.contains { $0.description == expectedMove },
                          "Expected \(expectedMove), but it's missing")
        }
    }

    func testKingCantMoveIntoCheck() {
        let board = Board.empty.with((WK, e5),
                                     (BR, a4),
                                     (BQ, h6))

        let pos = Position(board: board, toMove: .white, moves: [])

        let expectedMoves = [
            "WKe5-d5",
            "WKe5-f5"
        ]

        let moves = pos.legalMoves()

        XCTAssertEqual(moves.count, expectedMoves.count)

        for expectedMove in expectedMoves {
            XCTAssertTrue(moves.contains { $0.description == expectedMove },
                          "Expected \(expectedMove), but it's missing")
        }
    }

    func testMoveMustGetKingOutOfCheck() {
        let board = Board.empty.with((BK, e8),
                                     (BN, g8),
                                     (BP, a7),
                                     (BP, b7),
                                     (WR, d1),
                                     (WQ, e1),
                                     (WR, f1))

        let pos = Position(board: board, toMove: .black, moves: [])

        let expectedMoves = [
            "BNg8-e7"
            // All other moves leave king in check
        ]

        let moves = pos.legalMoves()

        XCTAssertEqual(moves.count, expectedMoves.count)

        for expectedMove in expectedMoves {
            XCTAssertTrue(moves.contains { $0.description == expectedMove },
                          "Expected \(expectedMove), but it's missing")
        }
    }

    func testWhiteCastleKingside() {
        let board = Board.empty.with((WK, e1),
                                     (WR, h1))

        let pos = Position(board: board, toMove: .white, moves: [])
        XCTAssertTrue(pos.whiteCanCastleKingside)
        XCTAssertTrue(pos.whiteCanCastleQueenside)

        let moves = pos.legalMoves()

        let expectedMove = Move.castleKingside(player: .white)

        XCTAssertTrue(moves.contains { $0 == expectedMove },
                      "expect O-O as a legal move")

        let pos2 = pos.after(expectedMove)
        XCTAssertFalse(pos2.whiteCanCastleKingside)
        XCTAssertFalse(pos2.whiteCanCastleQueenside)
    }

    func testBlackCastleKingside() {
        let board = Board.empty.with((BK, e8),
                                     (BR, h8))

        let pos = Position(board: board, toMove: .black, moves: [])
        XCTAssertTrue(pos.blackCanCastleKingside)
        XCTAssertTrue(pos.blackCanCastleQueenside)

        let moves = pos.legalMoves()

        let expectedMove = Move.castleKingside(player: .black)

        XCTAssertTrue(moves.contains { $0 == expectedMove },
                      "expect O-O as a legal move")

        let pos2 = pos.after(expectedMove)
        XCTAssertFalse(pos2.blackCanCastleKingside)
        XCTAssertFalse(pos2.blackCanCastleQueenside)
    }

    func testWhiteCastleQueenside() {
        let board = Board.empty.with((WK, e1),
                                     (WR, a1))

        let pos = Position(board: board, toMove: .white, moves: [])
        XCTAssertTrue(pos.whiteCanCastleKingside)
        XCTAssertTrue(pos.whiteCanCastleQueenside)

        let moves = pos.legalMoves()

        let expectedMove = Move.castleQueenside(player: .white)

        XCTAssertTrue(moves.contains { $0 == expectedMove },
                      "expect O-O-O as a legal move")

        let pos2 = pos.after(expectedMove)
        XCTAssertFalse(pos2.whiteCanCastleKingside)
        XCTAssertFalse(pos2.whiteCanCastleQueenside)
    }

    func testBlackCastleQueenside() {
        let board = Board.empty.with((BK, e8),
                                     (BR, a8))

        let pos = Position(board: board, toMove: .black, moves: [])
        XCTAssertTrue(pos.blackCanCastleKingside)
        XCTAssertTrue(pos.blackCanCastleQueenside)

        let moves = pos.legalMoves()

        let expectedMove = Move.castleQueenside(player: .black)

        XCTAssertTrue(moves.contains { $0 == expectedMove },
                      "expect O-O-O as a legal move")

        let pos2 = pos.after(expectedMove)
        XCTAssertFalse(pos2.blackCanCastleKingside)
        XCTAssertFalse(pos2.blackCanCastleQueenside)
    }

    func testRejectWhiteCastleKingside() {
        let board = Board.empty.with((WK, e1),
                                     (WR, h1))

        let pos = Position(board: board, toMove: .white, moves: [],
                           castlingOptions: CastlingOptions.none)

        let moves = pos.legalMoves()

        let rejectedMove = Move.castleKingside(player: .white)

        XCTAssertFalse(moves.contains { $0 == rejectedMove },
                       "O-O is not a legal move")
    }

    func testRejectBlackCastleKingside() {
        let board = Board.empty.with((BK, e8),
                                     (BR, h8))

        let pos = Position(board: board, toMove: .black, moves: [],
                           castlingOptions: CastlingOptions.none)

        let moves = pos.legalMoves()

        let rejectedMove = Move.castleKingside(player: .black)

        XCTAssertFalse(moves.contains { $0 == rejectedMove },
                       "O-O is not a legal moves")
    }

    func testRejectWhiteCastleQueenside() {
        let board = Board.empty.with((WK, e1),
                                     (WR, a1))

        let pos = Position(board: board, toMove: .white, moves: [],
                           castlingOptions: CastlingOptions.none)

        let moves = pos.legalMoves()

        let rejectedMove = Move.castleQueenside(player: .white)

        XCTAssertFalse(moves.contains { $0 == rejectedMove },
                       "O-O-O is not a legal move")
    }

    func testRejectBlackCastleQueenside() {
        let board = Board.empty.with((BK, e8),
                                     (BR, a8))

        let pos = Position(board: board, toMove: .black, moves: [],
                           castlingOptions: CastlingOptions.none)

        let moves = pos.legalMoves()

        let rejectedMove = Move.castleQueenside(player: .black)
        
        XCTAssertFalse(moves.contains { $0 == rejectedMove },
                       "O-O-O is not a legal move")
    }

    func testRejectWhiteCastleKingsideWhenInCheck() {
        let board = Board.empty.with((WK, e1),
                                     (WR, h1),
                                     (BR, e8))

        let pos = Position(board: board, toMove: .white, moves: [])

        let moves = pos.legalMoves()

        let rejectedMove = Move.castleKingside(player: .white)

        XCTAssertFalse(moves.contains { $0 == rejectedMove },
                       "O-O is not a legal move in check")
    }

    func testRejectWhiteCastleKingsideIfF1IsUnderAttack() {
        let board = Board.empty.with((WK, e1),
                                     (WR, h1),
                                     (BR, f8))

        let pos = Position(board: board, toMove: .white, moves: [])

        let moves = pos.legalMoves()

        let rejectedMove = Move.castleKingside(player: .white)

        XCTAssertFalse(moves.contains { $0 == rejectedMove },
                       "O-O is not a legal move if f1 is under attack")
    }

    func testRejectWhiteCastleQueensideWhenInCheck() {
        let board = Board.empty.with((WK, e1),
                                     (WR, a1),
                                     (BR, e8))

        let pos = Position(board: board, toMove: .white, moves: [])

        let moves = pos.legalMoves()

        let rejectedMove = Move.castleQueenside(player: .white)

        XCTAssertFalse(moves.contains { $0 == rejectedMove },
                       "O-O-O is not a legal move in check")
    }

    func testRejectWhiteCastleQueensideIfD1IsUnderAttack() {
        let board = Board.empty.with((WK, e1),
                                     (WR, a1),
                                     (BR, d8))

        let pos = Position(board: board, toMove: .white, moves: [])

        let moves = pos.legalMoves()

        let rejectedMove = Move.castleQueenside(player: .white)

        XCTAssertFalse(moves.contains { $0 == rejectedMove },
                       "O-O-O is not a legal move if d1 is under attack")
    }

    func testRejectBlackCastleKingsideWhenInCheck() {
        let board = Board.empty.with((BK, e8),
                                     (BR, h8),
                                     (WR, e1))

        let pos = Position(board: board, toMove: .black, moves: [])

        let moves = pos.legalMoves()

        let rejectedMove = Move.castleKingside(player: .black)

        XCTAssertFalse(moves.contains { $0 == rejectedMove },
                       "O-O is not a legal move in check")
    }

    func testRejectBlackCastleKingsideIfF8IsUnderAttack() {
        let board = Board.empty.with((BK, e8),
                                     (BR, h8),
                                     (WR, f1))

        let pos = Position(board: board, toMove: .black, moves: [])

        let moves = pos.legalMoves()

        let rejectedMove = Move.castleKingside(player: .black)

        XCTAssertFalse(moves.contains { $0 == rejectedMove },
                       "O-O is not a legal move if f8 is under attack")
    }

    func testRejectBlackCastleQueensideWhenInCheck() {
        let board = Board.empty.with((BK, e8),
                                     (BR, a8),
                                     (WR, e1))

        let pos = Position(board: board, toMove: .black, moves: [])

        let moves = pos.legalMoves()

        let rejectedMove = Move.castleQueenside(player: .black)

        XCTAssertFalse(moves.contains { $0 == rejectedMove },
                       "O-O-O is not a legal move in check")
    }

    func testRejectWhiteCastleQueensideIfD8IsUnderAttack() {
        let board = Board.empty.with((BK, e8),
                                     (BR, a8),
                                     (WR, d1))

        let pos = Position(board: board, toMove: .black, moves: [])

        let moves = pos.legalMoves()

        let rejectedMove = Move.castleQueenside(player: .black)

        XCTAssertFalse(moves.contains { $0 == rejectedMove },
                       "O-O-O is not a legal move if d8 is under attack")
    }

    func testWhiteEnPassantCapture() {
        let board = Board.empty.with((WP, e5),
                                     (BP, d7))

        let pos = Position(board: board, toMove: .black, moves: [])

        let pos1 = pos.after(.move(piece: BP, from: d7, to: d5))

        XCTAssertEqual(pos1.enPassantCaptureLocation, d6)

        let moves = pos1.legalMoves()

        let expectedMove = Move.enPassantCapture(player: .white, from: e5, to: d6)

        XCTAssertTrue(moves.contains { $0 == expectedMove },
                      "En-passant capture at d6 expected")
    }

    func testBlackEnPassantCapture() {
        let board = Board.empty.with((WP, e2),
                                     (BP, f4))

        let pos = Position(board: board, toMove: .white, moves: [])

        let pos1 = pos.after(.move(piece: WP, from: e2, to: e4))

        XCTAssertEqual(pos1.enPassantCaptureLocation, e3)

        let moves = pos1.legalMoves()

        let expectedMove = Move.enPassantCapture(player: .black, from: f4, to: e3)

        XCTAssertTrue(moves.contains { $0 == expectedMove },
                      "En-passant capture at e3 expected")
    }

    func testPromoteCaptures() {
        let board = Board.empty.with((WP, g7),
                                     (BR, h8))

        let pos = Position(board: board, toMove: .white, moves: [])

        let moves = pos.legalMoves()

        for kind in PieceKind.promotionKinds {
            let expectedMove = Move.promoteCapture(player: .white,
                                                   from: g7, to: h8,
                                                   captured: .rook,
                                                   promoted: kind)

            XCTAssertTrue(moves.contains { $0 == expectedMove },
                          "Capture and promote to \(kind) expected")
        }
    }
}
