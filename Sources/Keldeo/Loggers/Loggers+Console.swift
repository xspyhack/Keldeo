//
//  TTYLogger.swift
//  Keldeo
//
//  Created by bl4ckra1sond3tre on 2018/8/20.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import Foundation

public extension Loggers {

    /// A logger for Xcode console output.
    static func console(level: Level = .info,
                        formatter: Formatting) -> Logging {
        return Logging(name: "com.xspyhack.ConsoleLogger",
                       level: level,
                       log: { Swift.print(formatter.format($0)) })
    }
}
