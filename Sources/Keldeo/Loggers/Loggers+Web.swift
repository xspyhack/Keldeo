//
//  WebLogger.swift
//  Keldeo
//
//  Created by bl4ckra1sond3tre on 2018/8/25.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import Foundation

public extension Loggers {

    /// A remote logger for send log message to web.
    /// With WebLogger, we can debug with Web Broswer like Safari.
    static func web(level: Level = .info, formatter: Formatting) -> Logging {
        func log(message: Message) {
            // Send to web
        }

        func start() {
            // Setup connection
        }

        func teardown() {
            // Close connection
        }

        return Logging(name: "com.xspyhack.WebLogger",
                       level: level,
                       log: log,
                       start: start,
                       teardown: teardown)
    }
}
