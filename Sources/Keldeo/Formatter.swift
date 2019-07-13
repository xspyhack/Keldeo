//
//  Formatter.swift
//  Keldeo
//
//  Created by bl4ckra1sond3tre on 2018/8/20.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import Foundation

/// Log message formatter
public protocol Formatter {

    /// Format log message to plain string
    ///
    /// - Parameter message: log message
    /// - Returns: plain string
    func format(message: Message) -> String
}
