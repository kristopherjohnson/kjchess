//
//  main.swift
//  kjchess-cli
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Darwin
import os.log

// Disable output buffering
setbuf(__stdoutp, nil)

// TODO: Logging should be set by a command-line option
isLogEnabled = true

if isLogEnabled { os_log("kjchess-cli starting", log: mainLog) }

do {
    let engine = UCIEngine()
    try engine.runCommandLoop()

    if isLogEnabled { os_log("kjchess-cli exiting", log: mainLog) }
    exit(0)
}
catch (let error) {
    if isLogEnabled {
        os_log("kjchess-cli error: %{public}@", log: mainLog, error.localizedDescription)
    }
    print("info string error: \(error.localizedDescription)")
    exit(1)
}
