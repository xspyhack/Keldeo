//
//  OSLogger.swift
//  Keldeo
//
//  Created by alex.huo on 2019/5/1.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import Foundation
import os

extension Loggers {

    /// A logger use `os_log` to log messages.
    public struct OS: Logging {
        public var formatter: Formatter
        public var level: Level
        private let log: OSLog

        public func log(message: Message) {
            // you may explicitly declare the string public using the keyword public.
            // For example, %{public}s.
            os_log("%@", log: log, type: Loggers.OS.logType(forLevel: message.level),
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
        }
    }
}

extension Loggers.OS: Hashable {
    public static func == (lhs: Loggers.OS, rhs: Loggers.OS) -> Bool {
        return lhs.level == rhs.level && lhs.name == rhs.name
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(level)
    }
}

extension Loggers.OS {
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
