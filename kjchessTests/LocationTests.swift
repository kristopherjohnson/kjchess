//
//  LocationTests.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import XCTest
import kjchess

class LocationTests: XCTestCase {

    func testCharacterInitializer() {
        let loc_a1 = Location(Character("a"), Character("1"))
        XCTAssertEqual(loc_a1, a1)

        let loc_b2 = Location(Character("b"), Character("2"))
        XCTAssertEqual(loc_b2, b2)

        let loc_c3 = Location(Character("c"), Character("3"))
        XCTAssertEqual(loc_c3, c3)

        let loc_d4 = Location(Character("d"), Character("4"))
        XCTAssertEqual(loc_d4, d4)

        let loc_e5 = Location(Character("e"), Character("5"))
        XCTAssertEqual(loc_e5, e5)

        let loc_f6 = Location(Character("f"), Character("6"))
        XCTAssertEqual(loc_f6, f6)

        let loc_g7 = Location(Character("g"), Character("7"))
        XCTAssertEqual(loc_g7, g7)

        let loc_h8 = Location(Character("h"), Character("8"))
        XCTAssertEqual(loc_h8, h8)
    }

    func testCharacterInitializerRejections() {
        let loc_aa = Location(Character("a"), Character("a"))
        XCTAssertNil(loc_aa)

        let loc_11 = Location(Character("1"), Character("1"))
        XCTAssertNil(loc_11)

        let loc_a9 = Location(Character("a"), Character("9"))
        XCTAssertNil(loc_a9)

        let loc_i1 = Location(Character("i"), Character("1"))
        XCTAssertNil(loc_i1)

        let loc_5e = Location(Character("5"), Character("e"))
        XCTAssertNil(loc_5e)
    }

    func testStringInitializer() {
        let loc_a1 = Location("a1")
        XCTAssertEqual(loc_a1, a1)

        let loc_b2 = Location("b2")
        XCTAssertEqual(loc_b2, b2)

        let loc_c3 = Location("c3")
        XCTAssertEqual(loc_c3, c3)

        let loc_d4 = Location("d4")
        XCTAssertEqual(loc_d4, d4)

        let loc_e5 = Location("e5")
        XCTAssertEqual(loc_e5, e5)

        let loc_f6 = Location("f6")
        XCTAssertEqual(loc_f6, f6)

        let loc_g7 = Location("g7")
        XCTAssertEqual(loc_g7, g7)

        let loc_h8 = Location("h8")
        XCTAssertEqual(loc_h8, h8)
    }

    func testStringInitializerRejections() {
        let loc_aa = Location("aa")
        XCTAssertNil(loc_aa)

        let loc_11 = Location("11")
        XCTAssertNil(loc_11)

        let loc_a9 = Location("a9")
        XCTAssertNil(loc_a9)

        let loc_i1 = Location("i1")
        XCTAssertNil(loc_i1)

        let loc_5e = Location("5e")
        XCTAssertNil(loc_5e)

        let loc_ = Location("")
        XCTAssertNil(loc_)

        let loc_a = Location("a")
        XCTAssertNil(loc_a)

        let loc_1 = Location("1")
        XCTAssertNil(loc_1)

        let loc_e5e = Location("e5e")
        XCTAssertNil(loc_e5e)
    }
}
