import Foundation

/// Loggers management, exposes all logging mechanisms
public class Logger {

    /// Singlethon
    public static let shared = Logger()

    //private var loggerQueue = DispatchQueue(label: "com.xspyhack.logger.logger", attributes: .concurrent)

    private var queue = DispatchQueue(label: "com.xspyhack.logger.queue")

    /// All loggers set
    public private(set) var loggers: Set<AnyLogger> = []

    public init() {
        // Observer UIApplication will terminate notification to flush logs
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(Logger.applicationWillTerminate(_:)),
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

public extension Logger {

    /// Add logger.
    /// You must use `AnyLogger(_:)` to wrap your logger`
    ///
    /// - Parameters:
    ///   - logger: the logger
    public func add(_ logger: AnyLogger) {
        loggers.update(with: logger)
    }

    /// Remove specific logger
    ///
    /// - Parameter logger: the logger to be remove
    public func remove(_ logger: AnyLogger) {
        loggers.remove(logger)
    }

    /// Remove all added logger
    public func removeAll() {
        loggers.removeAll()
    }
}

// MARK: - Log message

public extension Logger {

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

/// The convenience API for prepare log message
public struct Log {

    public static func e(_ message: @autoclosure () -> String, level: Level = .error, context: Int = 0, file: String = #file, function: StaticString = #function, line: UInt = #line, asynchronous: Bool = false) {
        log(message, level: level, flag: .error, context: context, file: file, function: function, line: line, asynchronous: asynchronous)
    }

    public static func w(_ message: @autoclosure () -> String, level: Level = .warning, context: Int = 0, file: String = #file, function: StaticString = #function, line: UInt = #line, asynchronous: Bool = true) {
        log(message, level: level, flag: .warning, context: context, file: file, function: function, line: line, asynchronous: asynchronous)
    }

    public static func i(_ message: @autoclosure () -> String, level: Level = .info, context: Int = 0, file: String = #file, function: StaticString = #function, line: UInt = #line, asynchronous: Bool = true) {
        log(message, level: level, flag: .info, context: context, file: file, function: function, line: line, asynchronous: asynchronous)
    }

    public static func d(_ message: @autoclosure () -> String, level: Level = .debug, context: Int = 0, file: String = #file, function: StaticString = #function, line: UInt = #line, asynchronous: Bool = true) {
        log(message, level: level, flag: .debug, context: context, file: file, function: function, line: line, asynchronous: asynchronous)
    }

    public static func log(_ message: @autoclosure () -> String, level: Level, flag: Flag, context: Int, file: String, function: StaticString, line: UInt, asynchronous: Bool) {

        let message = Message(message: message(), level: level, flag: flag, context: context, file: file, function: function, line: line, timestamp: Date())

        Logger.shared.log(message: message, asynchronous: asynchronous)
    }
}
