//
//  EvaluationTests.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import XCTest
import kjchess

class EvaluationTests: XCTestCase {

    func testEvaluateNewGame() {
        let pos = Position.newGame()
        let eval = Evaluation(pos)

        XCTAssertEqual(pos, eval.position)

        XCTAssertEqual(Array(pos.legalMoves()), eval.moves)

        XCTAssertEqual(16, eval.whitePieces.count)
        XCTAssertEqual(16, eval.blackPieces.count)

        XCTAssertEqual(0.0, eval.materialScore)
    }

    func testEvaluateAfterBlackPawnLoss() {
        let pos = try! Position.newGame().after(coordinateMoves:
            "e2e4", "d7d5", "e4d5")

        let eval = Evaluation(pos)

        XCTAssertEqual(1.0, eval.materialScore,
                       "White is ahead by a pawn")
    }

    func testEvaluateAfterWhiteKnightLoss() {
        let pos = try! Position.newGame().after(coordinateMoves:
            "g1f3", "e7e5", "f3d4", "e5d4")

        let eval = Evaluation(pos)

        XCTAssertEqual(-3.0, eval.materialScore,
                       "Black is ahead by a minor piece")
    }
}
