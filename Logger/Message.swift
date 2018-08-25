import Foundation

public struct Message {

    public let message: String

    public let level: Level

    public let flag: Flag

    public let context: Int

    public let file: StaticString

    public let function: StaticString

    public let line: UInt

    public let timestamp: Date

    public init(message: String, level: Level, flag: Flag, context: Int, file: StaticString, function: StaticString, line: UInt, timestamp: Date) {
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
