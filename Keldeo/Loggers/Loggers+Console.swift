//
//  TTYLogger.swift
//  Keldeo
//
//  Created by bl4ckra1sond3tre on 2018/8/20.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import Foundation

extension Loggers {

    /// A logger for Xcode console output.
    public struct Console: Logging {
        public var formatter: Formatter
        public var level: Level

        public func log(message: Message) {
            // With Swift, just print
            // The Swift.print function will not sent the message to Apple Console System
            Swift.print(formatter.format(message: message))
        }

        public var name: String {
            return "com.xspyhack.ConsoleLogger"
        }

        public init(level: Level = .info, formatter: Formatter) {
            self.level = level
            self.formatter = formatter
        }
    }
}

extension Loggers.Console: Hashable {
    public static func == (lhs: Loggers.Console, rhs: Loggers.Console) -> Bool {
        return lhs.level == rhs.level && lhs.name == rhs.name
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(level)
    }
}
