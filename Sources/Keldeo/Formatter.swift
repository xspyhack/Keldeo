//
//  Formatter.swift
//  Keldeo
//
//  Created by bl4ckra1sond3tre on 2018/8/20.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import Foundation

/// Log message formatter
public struct Formatting {
    /// Format log message to plain string
    public let format: (Message) -> String

    public init(format: @escaping (Message) -> String) {
        self.format = format
    }
}
