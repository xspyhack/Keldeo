import Foundation

/// Log message formatter
public protocol LogFormatter {

    /// Format log message to plain string
    ///
    /// - Parameter message: log message
    /// - Returns: plain string
    func format(message: Message) -> String
}
