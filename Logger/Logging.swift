import Foundation

public enum Level: Int {
    case off = 0
    case error = 1
    case warning = 11
    case info = 111
    case debug = 1111
    case all = 1111111
}

//public struct Level {
//    public static let off: [Flag] = []
//    public static let error: [Flag] = Level.off + [.error]
//    public static let warning: [Flag] = Level.error + [.warning]
//    public static let info: [Flag] = Level.warning + [.info]
//    public static let debug: [Flag] = Level.info + [.debug]
//    public static let all: [Flag] = Level.debug
//}

public struct Flag: OptionSet {

    public let rawValue: Int

    public static let error = Flag(rawValue: 1 << 0)
    public static let warning = Flag(rawValue: 1 << 1)
    public static let info = Flag(rawValue: 1 << 2)
    public static let debug = Flag(rawValue: 1 << 3)

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

/// Logging protocol, describes a logger behavior.
public protocol Logging: Hashable {

    /// Log formatter for format log message before output
    var formatter: Formatter { get }

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

    var formatter: Formatter { get }

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

    var formatter: Formatter {
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

    init<T: Logging>(_ box: T) {
        self.box = ConcreteLoggerBox(box)
    }
}

extension AnyLogger: Logging {

    public var formatter: Formatter {
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
