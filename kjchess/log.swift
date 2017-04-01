//
//  log.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import os.log

/// If set `true`, then write messages to log.
var isLogEnabled = false

let logSubsystem = "com.kristopherjohnson.net.kjchess"

/// Log for main.swift
let mainLog = OSLog(subsystem: logSubsystem, category: "main")

/// Log for the UCIEngine.
let uciLog = OSLog(subsystem: logSubsystem, category: "uci")

/// Log for parse errors.
let parseLog = OSLog(subsystem: logSubsystem, category: "parse")
