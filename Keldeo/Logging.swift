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

/// Logging protocol, describes a logger behavior.
public protocol Logging: Hashable {

    /// Log formatter for format log message before output
    var formatter: LogFormatter { get }

    /// Logger name
    var name: String { get }

    /// Logger level for filter output
    var level: Level { get }

    /// Log method, use this method to output log message.
    ///
    /// - Parameter message: log message
    func log(message: Message)

    /// Implemented to flush all pending IO
    func flush()

    /// Timing for setup tasks
    func start()

    /// Timing for teardown tasks
    func teardown()
}

public extension Logging {

    var name: String {
        return "Unified"
    }

    func flush() {}

    func start() {}

    func teardown() {}
}

// MARK: - AnyLogger

internal func _abstract(file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError("Abstract method must be overridden", file: file, line: line)
}

protocol AnyLoggerBox {

    func unbox<T: Logging>() -> T?

    var formatter: LogFormatter { get }

    var level: Level { get }

    func log(message: Message)

    func start()

    func teardown()

    func flush()

    // hashable
    var hashValue: Int { get }

    func isEqual(to: AnyLoggerBox) -> Bool?
}

struct ConcreteLoggerBox<Base: Logging>: AnyLoggerBox {

    var base: Base

    init(_ base: Base) {
        self.base = base
    }

    var formatter: LogFormatter {
        return base.formatter
    }

    var level: Level {
        return base.level
    }

    func unbox<T : Logging>() -> T? {
        return (self as AnyLoggerBox as? ConcreteLoggerBox<T>)?.base
    }

    func log(message: Message) {
        base.log(message: message)
    }

    func flush() {
        base.flush()
    }

    func start() {
        base.start()
    }

    func teardown() {
        base.teardown()
    }

    var hashValue: Int {
        return base.hashValue
    }

    func isEqual(to other: AnyLoggerBox) -> Bool? {
        guard let other: Base = other.unbox() else {
            return nil
        }
        return other == base
    }
}

public struct AnyLogger {

    private var box: AnyLoggerBox

    public init<T: Logging>(_ box: T) {
        self.box = ConcreteLoggerBox(box)
    }
}

extension AnyLogger: Logging {

    public var formatter: LogFormatter {
        return box.formatter
    }

    public var level: Level {
        return box.level
    }

    public func log(message: Message) {
        box.log(message: message)
    }

    public func flush() {
        box.flush()
    }

    public func start() {
        box.start()
    }

    public func teardown() {
        box.teardown()
    }
}

extension AnyLogger: Hashable {

    public static func == (lhs: AnyLogger, rhs: AnyLogger) -> Bool {
        if let result = lhs.box.isEqual(to: rhs.box) {
            return result
        }

        return false
    }

    public var hashValue: Int {
        return box.hashValue
    }
}
