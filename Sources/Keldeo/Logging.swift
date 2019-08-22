//
//  Logging.swift
//  Keldeo
//
//  Created by bl4ckra1sond3tre on 2018/8/20.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import Foundation

public enum Level: Int {
    case off = 0
    case error = 1 // Flag.error | Level.off
    case warning = 3 // Flag.warning | Level.error
    case info = 7 // Flag.info | Level.warning
    case debug = 15 // Flag.debug | Level.info
}

public struct Flag: OptionSet {
    public let rawValue: Int

    public static let error = Flag(rawValue: 1 << 0) // 1
    public static let warning = Flag(rawValue: 1 << 1) // 2
    public static let info = Flag(rawValue: 1 << 2) // 4
    public static let debug = Flag(rawValue: 1 << 3) // 8

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

/// Logging, describes a logger behavior.
public struct Logging {

    /// Logger name
    public let name: String

    /// Logger level for filter output
    public let level: Level

    /// Log method, use this method to output log message.
    public let log: (Message) -> Void

    /// Implemented to flush all pending IO
    public let flush: (() -> Void)?

    /// Timing for setup tasks
    public let start: (() -> Void)?

    /// Timing for teardown tasks
    public let teardown: (() -> Void)?

    public init(name: String,
                level: Level,
                log: @escaping (Message) -> Void,
                flush: (() -> Void)? = nil,
                start: (() -> Void)? = nil,
                teardown: (() -> Void)? = nil) {
        self.name = name
        self.level = level
        self.log = log
        self.flush = flush
        self.start = start
        self.teardown = teardown
    }
}

extension Logging: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(level)
    }

    public static func == (lhs: Logging, rhs: Logging) -> Bool {
        return lhs.level == rhs.level && lhs.name == rhs.name
    }
}
