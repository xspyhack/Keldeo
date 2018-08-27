//
//  Message.swift
//  Keldeo
//
//  Created by bl4ckra1sond3tre on 2018/8/20.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import Foundation

public struct Message {

    public let message: String

    public let level: Level

    public let flag: Flag

    public let context: Int

    public let file: String

    public let function: StaticString

    public let line: UInt

    public let timestamp: Date

    public init(message: String, level: Level, flag: Flag, context: Int, file: String, function: StaticString, line: UInt, timestamp: Date) {
        self.message = message
        self.level = level
        self.flag = flag
        self.context = context
        self.file = file
        self.function = function
        self.line = line
        self.timestamp = timestamp
    }
}
