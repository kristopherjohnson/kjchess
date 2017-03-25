//
//  Position_generateMovesTests.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import XCTest
@testable import kjchess

class Position_generateMovesTests: XCTestCase {

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

        let moves = Array(pos.generateMoves())

        XCTAssertEqual(moves.count, expectedMoves.count)

        for expectedMove in expectedMoves {
            XCTAssertTrue(moves.contains { $0.description == expectedMove },
                          "Expected \(expectedMove), but it's missing")
        }
    }

    func testBlackNewGameMoves() {
        let board = Board.newGame.with([(WP,  e4),
                                        (nil, e2)])

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

        let moves = Array(pos.generateMoves())

        XCTAssertEqual(moves.count, expectedMoves.count)

        for expectedMove in expectedMoves {
            XCTAssertTrue(moves.contains { $0.description == expectedMove },
                          "Expected \(expectedMove), but it's missing")
        }

        for move in moves {
            XCTAssertFalse(move.isCapture, "Should not be a capturing move")
        }
    }

    func testWhitePawnCaptures() {
        let board = Board.empty.with([(WP, e4),
                                      (BB, d5),
                                      (BP, e5),
                                      (BN, f5)])

        let pos = Position(board: board, toMove: .white, moves: [])

        let expectedMoves = [
            "WPe4xBd5",
            "WPe4xNf5"
        ]

        let moves = Array(pos.generateMoves())

        XCTAssertEqual(moves.count, expectedMoves.count)

        for expectedMove in expectedMoves {
            XCTAssertTrue(moves.contains { $0.description == expectedMove },
                          "Expected \(expectedMove), but it's missing")
        }
    }

    func testBlackPawnCaptures() {
        let board = Board.empty.with([(BP, d5),
                                      (WB, c4),
                                      (WP, d4),
                                      (WN, e4)])

        let pos = Position(board: board, toMove: .black, moves: [])

        let expectedMoves = [
            "BPd5xBc4",
            "BPd5xNe4"
        ]

        let moves = Array(pos.generateMoves())

        XCTAssertEqual(moves.count, expectedMoves.count)

        for expectedMove in expectedMoves {
            XCTAssertTrue(moves.contains { $0.description == expectedMove },
                          "Expected \(expectedMove), but it's missing")
        }
    }
    
    func testKnightMovesEmptyBoard() {
        let board = Board.empty.with(WN, at: d4)

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

        let moves = Array(pos.generateMoves())

        XCTAssertEqual(moves.count, expectedMoves.count)

        for expectedMove in expectedMoves {
            XCTAssertTrue(moves.contains { $0.description == expectedMove },
                          "Expected \(expectedMove), but it's missing")
        }
    }

    func testKnightMovesAllBlocked() {
        // Knight at d4 with pawns at all locations it could jump to.
        let board = Board.empty.with([(WN, d4),
                                      (WP, c6),
                                      (WP, e6),
                                      (WP, f5),
                                      (WP, f3),
                                      (WP, e2),
                                      (WP, c2),
                                      (WP, b3),
                                      (WP, b5)])

        let pos = Position(board: board, toMove: .white, moves: [])

        // Note: Filter out the moves that the pawns could make.
        let moves = Array(pos.generateMoves()).filter { $0.from == d4 }

        XCTAssertEqual(0, moves.count, "No moves by the knight are possible")
    }

    func testKnightCaptures() {
        // White knight at d4 with black queens at every location can jump to
        let board = Board.empty.with([(WN, d4),
                                      (BQ, c6),
                                      (BQ, e6),
                                      (BQ, f5),
                                      (BQ, f3),
                                      (BQ, e2),
                                      (BQ, c2),
                                      (BQ, b3),
                                      (BQ, b5)])

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

        let moves = Array(pos.generateMoves())

        XCTAssertEqual(moves.count, expectedMoves.count)

        for expectedMove in expectedMoves {
            XCTAssertTrue(moves.contains { $0.description == expectedMove },
                          "Expected \(expectedMove), but it's missing")
        }
    }

    func testRookMovesEmptyBoard() {
        let board = Board.empty.with(WR, at: d4)

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

        let moves = Array(pos.generateMoves())

        XCTAssertEqual(moves.count, expectedMoves.count)

        for expectedMove in expectedMoves {
            XCTAssertTrue(moves.contains { $0.description == expectedMove },
                          "Expected \(expectedMove), but it's missing")
        }
    }

    func testRookCaptures() {
        let board = Board.empty.with([(WR, d4),
                                      (BQ, d1),
                                      (BQ, d2),
                                      (BQ, d7),
                                      (BQ, d8),
                                      (BQ, a4),
                                      (BQ, b4),
                                      (BQ, g4),
                                      (BQ, h4)])

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

        let moves = Array(pos.generateMoves())

        XCTAssertEqual(moves.count, expectedMoves.count)

        for expectedMove in expectedMoves {
            XCTAssertTrue(moves.contains { $0.description == expectedMove },
                          "Expected \(expectedMove), but it's missing")
        }
    }

    func testBishopMovesEmptyBoard() {
        let board = Board.empty.with(WB, at: e4)

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

        let moves = Array(pos.generateMoves())

        XCTAssertEqual(moves.count, expectedMoves.count)

        for expectedMove in expectedMoves {
            XCTAssertTrue(moves.contains { $0.description == expectedMove },
                          "Expected \(expectedMove), but it's missing")
        }
    }

    func testBishopCaptures() {
        let board = Board.empty.with([(BB, d4),
                                      (WQ, b6),
                                      (WQ, a7),
                                      (WQ, g7),
                                      (WQ, h8),
                                      (WQ, a1),
                                      (WQ, b2),
                                      (WQ, f2),
                                      (WQ, g1)])

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

        let moves = Array(pos.generateMoves())

        XCTAssertEqual(moves.count, expectedMoves.count)

        for expectedMove in expectedMoves {
            XCTAssertTrue(moves.contains { $0.description == expectedMove },
                          "Expected \(expectedMove), but it's missing")
        }
    }

    func testQueenEmptyBoard() {
        let board = Board.empty.with(BQ, at: c3)

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

        let moves = Array(pos.generateMoves())

        XCTAssertEqual(moves.count, expectedMoves.count)

        for expectedMove in expectedMoves {
            XCTAssertTrue(moves.contains { $0.description == expectedMove },
                          "Expected \(expectedMove), but it's missing")
        }
    }

    func testQueenCaptures() {
        let board = Board.empty.with([(BQ, d4),
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
                                      (WQ, d6)])

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

        let moves = Array(pos.generateMoves())

        XCTAssertEqual(moves.count, expectedMoves.count)

        for expectedMove in expectedMoves {
            XCTAssertTrue(moves.contains { $0.description == expectedMove },
                          "Expected \(expectedMove), but it's missing")
        }
    }
}
