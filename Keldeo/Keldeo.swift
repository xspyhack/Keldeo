//
//  Keldeo.swift
//  Keldeo
//
//  Created by bl4ckra1sond3tre on 2018/8/25.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import Foundation

/// Loggers management, exposes all logging mechanisms
public class Keldeo {

    /// Singlethon
    public static let shared = Keldeo()

    private var loggerQueue = DispatchQueue(label: "com.xspyhack.logger.logger", attributes: .concurrent)

    private var queue = DispatchQueue(label: "com.xspyhack.logger.queue")

    /// All loggers set
    public private(set) var loggers: Set<AnyLogger> = []

    public init() {
        // Observer UIApplication will terminate notification to flush logs
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(Keldeo.applicationWillTerminate(_:)),
                                               name: UIApplication.willTerminateNotification,
                                               object: nil)
    }

    deinit {
        loggers.forEach {
            $0.teardown()
        }

        loggers = []
    }

    /// Start new session
    public func start() {
        loggers.forEach {
            $0.start()
        }
    }

    @objc
    private func applicationWillTerminate(_ notification: Notification) {
        flush()
    }
}

// MARK: - Logger manager

public extension Keldeo {

    /// Add logger.
    /// You must use `AnyLogger(_:)` to wrap your logger
    ///
    /// - Parameters:
    ///   - logger: the logger
    public func add(_ logger: AnyLogger) {
        loggerQueue.async(flags: .barrier) {
            self.loggers.update(with: logger)
        }
    }

    /// Remove specific logger
    ///
    /// - Parameter logger: the logger to be remove
    public func remove(_ logger: AnyLogger) {
        loggerQueue.async(flags: .barrier) {
            self.loggers.remove(logger)
        }
    }

    /// Remove all added loggers
    public func removeAll() {
        loggerQueue.async(flags: .barrier) {
            self.loggers.removeAll()
        }
    }
}

// MARK: - Log message

public extension Keldeo {

    /// The primitive logging method
    ///
    /// - Parameters:
    ///   - message: the log message
    ///   - asynchronous: true if the logging is done async, false if you want to force sync
    public func log(message: Message, asynchronous: Bool) {

        let work = DispatchWorkItem {
            self.loggers.forEach { logger in
                guard message.flag.rawValue & logger.level.rawValue != 0 else {
                    return
                }
                logger.log(message: message)
            }
        }

        if asynchronous {
            queue.async(execute: work)
        } else {
            queue.sync(execute: work)
        }
    }

    /// Flush all pending logs synchronously
    public func flush() {
        let work = DispatchWorkItem {
            self.loggers.forEach { logger in
                logger.flush()
            }
        }

        queue.sync(execute: work)
    }
}

/// The convenience API for preparing log message
public struct Log {

    /// Log error level message
    public static func e(_ message: @autoclosure () -> String, level: Level = .error, context: Int = 0, file: String = #file, function: StaticString = #function, line: UInt = #line, asynchronous: Bool = false) {
        log(message, level: level, flag: .error, context: context, file: file, function: function, line: line, asynchronous: asynchronous)
    }

    /// Log warning level message
    public static func w(_ message: @autoclosure () -> String, level: Level = .warning, context: Int = 0, file: String = #file, function: StaticString = #function, line: UInt = #line, asynchronous: Bool = true) {
        log(message, level: level, flag: .warning, context: context, file: file, function: function, line: line, asynchronous: asynchronous)
    }

    /// Log info level message
    public static func i(_ message: @autoclosure () -> String, level: Level = .info, context: Int = 0, file: String = #file, function: StaticString = #function, line: UInt = #line, asynchronous: Bool = true) {
        log(message, level: level, flag: .info, context: context, file: file, function: function, line: line, asynchronous: asynchronous)
    }

    /// Log debug level message
    public static func d(_ message: @autoclosure () -> String, level: Level = .debug, context: Int = 0, file: String = #file, function: StaticString = #function, line: UInt = #line, asynchronous: Bool = true) {
        log(message, level: level, flag: .debug, context: context, file: file, function: function, line: line, asynchronous: asynchronous)
    }

    /// Log message
    public static func log(_ message: @autoclosure () -> String, level: Level, flag: Flag, context: Int, file: String, function: StaticString, line: UInt, asynchronous: Bool) {

        let message = Message(message: message(), level: level, flag: flag, context: context, file: file, function: function, line: line, timestamp: Date())

        Keldeo.shared.log(message: message, asynchronous: asynchronous)
    }
}
