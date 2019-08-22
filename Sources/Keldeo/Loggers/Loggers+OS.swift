//
//  OSLogger.swift
//  Keldeo
//
//  Created by alex.huo on 2019/5/1.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import Foundation
import os

public extension Loggers {

    /// A logger use `os_log` to log messages.
    static func os(level: Level = .info,
                   formatter: Formatting,
                   subsystem: String,
                   category: String) -> Logging {
        let log = OSLog(subsystem: subsystem, category: category)
        return os(level: level, formatter: formatter, log: log)
    }

    /// A logger use `os_log` to log messages.
    static func os(level: Level = .info,
                   formatter: Formatting,
                   log: OSLog) -> Logging {
        return Logging(name: "com.xspyhack.OSLogger",
                       level: level,
                       log: { message in
                        // you may explicitly declare the string public using the keyword public.
                        // For example, %{public}s.
                        os_log("%@", log: log,
                               type: Loggers.logType(forLevel: message.level),
                               formatter.format(message))
        })
    }
}

extension Loggers {
    fileprivate static func logType(forLevel level: Level) -> OSLogType {
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
