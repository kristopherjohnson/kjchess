//
//  bestMoveTests.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import XCTest
import kjchess

class bestMoveTests: XCTestCase {

    /// Number of times we repeat each test.
    ///
    /// This is intended to verify that the same "best" move is selected every time,
    /// and that we didn't just luckily choose the expected move randomly.
    let repeats = 4

    func testPreferCaptureOverMove() {
        let board = Board.empty.with((WQ, e4),
                                     (BQ, b7))

        let pos = Position(board: board, toMove: .white, moves: [])

        for _ in 0..<repeats {
            if let (move, _, pv) = bestMove(position: pos) {

                XCTAssertEqual(move,
                               .capture(piece: WQ, from: e4, to: b7, captured: .queen),
                               "Should always try to capture the queen")
                XCTAssertEqual(pv.count, 1)
                XCTAssertEqual(pv[0], move)
            }
            else {
                XCTFail("Unable to find a move")
            }
        }
    }

    func testCaptureHighestValuePiece() {
        let board = Board.empty.with((WP, e4),
                                     (BQ, d5),
                                     (BB, f5))

        let pos = Position(board: board, toMove: .white, moves: [])

        for _ in 0..<repeats {
            if let (move, _, pv) = bestMove(position: pos) {
                XCTAssertEqual(move,
                               .capture(piece: WP, from: e4, to: d5, captured: .queen),
                               "Should always capture the queen instead of the bishop")
                XCTAssertEqual(pv.count, 1)
                XCTAssertEqual(pv[0], move)
            }
            else {
                XCTFail("Unable to find a move")
            }
        }
    }

    func testAvoidBadExchange() {
        let board = Board.empty.with((WQ, e4),
                                     (BR, e6),
                                     (BP, d7),
                                     (BP, a4))

        let pos = Position(board: board, toMove: .white, moves: [])
        for _ in 0..<repeats {
            if let (move, _, pv) = bestMove(position: pos, searchDepth: 2) {
                XCTAssertEqual(move,
                               .capture(piece: WQ, from: e4, to: a4, captured: .pawn),
                               "Should capture the pawn instead of the rook")
                XCTAssertEqual(pv.count, 2)
                XCTAssertEqual(pv[0], move)
            }
            else {
                XCTFail("Unable to find a move")
            }
        }
    }
}
