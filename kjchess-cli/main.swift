//
//  main.swift
//  kjchess-cli
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Darwin

do {
    let engine = UCIEngine()
    try engine.runCommandLoop()
    exit(0)
}
catch (let error) {
    print("error: \(error)")
    exit(1)
}
