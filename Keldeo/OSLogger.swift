//
//  OSLogger.swift
//  Keldeo
//
//  Created by alex.huo on 2019/5/1.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import Foundation
import os

/// A logger use `os_log` to log messages.
public struct OSLogger: Logging {
    public var formatter: Formatter
    public var level: Level
    
    private let log: OSLog
    private let logType: OSLogType

    public func log(message: Message) {
        os_log("%@", log: log, type: logType,
               formatter.format(message: message))
    }

    public var name: String {
        return "com.xspyhack.OSLogger"
    }

    public init(level: Level = .info,
                formatter: Formatter,
                subsystem: String,
                category: String) {
        let log = OSLog(subsystem: subsystem, category: category)
        self.init(level: level, formatter: formatter, log: log)
    }

    public init(level: Level = .info,
                formatter: Formatter,
                log: OSLog) {
        self.level = level
        self.formatter = formatter
        self.log = log
        self.logType = OSLogger.logType(forLevel: level)
    }
}

extension OSLogger: Hashable {
    public static func == (lhs: OSLogger, rhs: OSLogger) -> Bool {
        return lhs.level == rhs.level && lhs.name == rhs.name
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(level)
    }
}

extension OSLogger {
    static func logType(forLevel level: Level) -> OSLogType {
        switch level {
        case .debug:
            return .debug
        case .info:
            return .info
        case .warning:
            return .default
        case .error:
            return .error
        default:
            return .fault
        }
    }
}
