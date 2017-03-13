//
//  kjchessTests.swift
//  kjchessTests
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import XCTest
@testable import kjchess

class kjchessTests: XCTestCase {
    
    func testInitialPosition() {
        let pos = Position.newGame()

        XCTAssertEqual(.white, pos.toMove)

        XCTAssertEqual(0, pos.moves.count)

        let b = pos.board

        XCTAssertEqual(WR, b[a1])
        XCTAssertEqual(WN, b[b1])
        XCTAssertEqual(WB, b[c1])
        XCTAssertEqual(WQ, b[d1])
        XCTAssertEqual(WK, b[e1])
        XCTAssertEqual(WB, b[f1])
        XCTAssertEqual(WN, b[g1])
        XCTAssertEqual(WR, b[h1])

        XCTAssertEqual(WP, b[a2])
        XCTAssertEqual(WP, b[b2])
        XCTAssertEqual(WP, b[c2])
        XCTAssertEqual(WP, b[d2])
        XCTAssertEqual(WP, b[e2])
        XCTAssertEqual(WP, b[f2])
        XCTAssertEqual(WP, b[g2])
        XCTAssertEqual(WP, b[h2])

        XCTAssertEqual(BR, b[a8])
        XCTAssertEqual(BN, b[b8])
        XCTAssertEqual(BB, b[c8])
        XCTAssertEqual(BQ, b[d8])
        XCTAssertEqual(BK, b[e8])
        XCTAssertEqual(BB, b[f8])
        XCTAssertEqual(BN, b[g8])
        XCTAssertEqual(BR, b[h8])

        XCTAssertEqual(BP, b[a7])
        XCTAssertEqual(BP, b[b7])
        XCTAssertEqual(BP, b[c7])
        XCTAssertEqual(BP, b[d7])
        XCTAssertEqual(BP, b[e7])
        XCTAssertEqual(BP, b[f7])
        XCTAssertEqual(BP, b[g7])
        XCTAssertEqual(BP, b[h7])

        for rank in 2...5 {
            for file in 0...7 {
                XCTAssertNil(b.at(file: file, rank: rank))
            }
        }
    }
}
