//
//  main.swift
//  kjchess-cli
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation
import os.log

/// Errors that can be thrown in this file.
enum CLIError: Error {
    case invalidOptionValue(optionName: String, invalidValue: String)
    case missingOptionValue(optionName: String)
}

extension CLIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .invalidOptionValue(optionName, invalidValue):
            return "\"\(invalidValue)\" is not a valid value for option --\"\(optionName)\""
        case let .missingOptionValue(optionName):
            return "Missing value for option \"--\(optionName)\""
        }
    }
}

/// Display version info.
/// 
/// - todo: Need a version major.minor version number. For now, just build timestamp.
func showVersion() {
    print("kjchess-cli v\(versionString) Copyright 2017 Kristopher Johnson")
}

/// Display information for command-line options.
func showHelp(optionDefinitions: [CommandLineOptionDefinition]) {
    print("usage: kjchess-cli [options]")
    print("options:")
    printHelp(optionDefinitions: optionDefinitions, firstColumnWidth: 30)
}

// Disable output buffering
setbuf(__stdoutp, nil)

do {
    let engine = UCIEngine()

    let optionDefinitions = [
        CommandLineOptionDefinition(name: "help",
                                    letter: "h",
                                    valueType: .noValue,
                                    briefHelp: "Show command-line help"),

        CommandLineOptionDefinition(name: "concurrent-tasks",
                                    letter: "t",
                                    valueType: .string("N"),
                                    briefHelp: "Number of concurrent tasks (default \(engine.concurrentTasks))"),

        CommandLineOptionDefinition(name: "enable-log",
                                    letter: "l",
                                    valueType: .noValue,
                                    briefHelp: "Enable system log output"),

        CommandLineOptionDefinition(name: "search-depth",
                                    letter: "d",
                                    valueType: .string("N"),
                                    briefHelp: "Search depth (default \(engine.searchDepth))"),

        CommandLineOptionDefinition(name: "version",
                                    letter: "v",
                                    valueType: .noValue,
                                    briefHelp: "Show version information")
    ]

    let options = try CommandLineParseResult(arguments: CommandLine.arguments,
                                             optionDefinitions: optionDefinitions)

    if options.isPresent(optionNamed: "version") {
        showVersion()
        exit(0)
    }

    if options.isPresent(optionNamed: "help") {
        showHelp(optionDefinitions: optionDefinitions)
        exit(0)
    }

    if options.isPresent(optionNamed: "enable-log") {
        isLogEnabled = true
    }

    if isLogEnabled {
        os_log("kjchess-cli launch: working directory: %{public}@; arguments: %{public}@",
               log: mainLog,
               FileManager.default.currentDirectoryPath,
               CommandLine.arguments.joined(separator: ", "))
    }

    if let searchDepthOptionValue = options.value(optionNamed: "search-depth") {
        switch searchDepthOptionValue {
        case .string(let value):
            if let numericValue = Int(value) {
                engine.searchDepth = numericValue
                if isLogEnabled {
                    os_log("search-depth set to %{public}d by command-line option",
                           log: mainLog,
                           engine.searchDepth)
                }
            }
            else {
                throw CLIError.invalidOptionValue(optionName: "search-depth",
                                                  invalidValue: value)
            }
        default:
            throw CLIError.missingOptionValue(optionName: "search-depth")
        }
    }

    if let concurrentTasksOptionValue = options.value(optionNamed: "concurrent-tasks") {
        switch concurrentTasksOptionValue {
        case .string(let value):
            if let numericValue = Int(value) {
                engine.concurrentTasks = numericValue
                if isLogEnabled {
                    os_log("concurrent-tasks set to %{public}d by command-line option",
                           log: mainLog,
                           engine.concurrentTasks)
                }
            }
            else {
                throw CLIError.invalidOptionValue(optionName: "concurrent-tasks",
                                                  invalidValue: value)
            }
        default:
            throw CLIError.missingOptionValue(optionName: "concurrent-tasks")
        }
    }

    try engine.runCommandLoop()

    if isLogEnabled { os_log("kjchess-cli exiting", log: mainLog) }
    exit(0)
}
catch (let error) {
    if isLogEnabled {
        os_log("kjchess-cli error: %{public}@", log: mainLog, error.localizedDescription)
    }
    // Write "info string ..." for UCI GUIs.
    print("info string error: \(error.localizedDescription)")
    exit(1)
}
