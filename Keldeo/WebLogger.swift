//
//  WebLogger.swift
//  Keldeo
//
//  Created by bl4ckra1sond3tre on 2018/8/25.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import Foundation

/// A remote logger for send log message to web.
/// With WebLogger, we can debug with Web Broswer like Safari.
public struct WebLogger: Logging {

    public var formatter: LogFormatter

    public var level: Level

    public var name: String {
        return "com.xspyhack.WebLogger"
    }

    public init(level: Level = .info, formatter: LogFormatter) {
        self.level = level
        self.formatter = formatter

        fatalError("Welcome for contribution")
    }

    public func log(message: Message) {
        // Send to web
    }

    public func start() {
        // Setup connection
    }

    public func teardown() {
        // Close connection
    }
}

extension WebLogger: Hashable {
    public static func == (lhs: WebLogger, rhs: WebLogger) -> Bool {
        return lhs.level == rhs.level && lhs.name == rhs.name
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(level)
    }
}
