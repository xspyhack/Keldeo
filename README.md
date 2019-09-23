# Keldeo

<p>
<a href="https://github.com/xspyhack/keldeo/actions"><img src="https://github.com/xspyhack/keldeo/workflows/Build/badge.svg" /></a>
<a href="https://github.com/Carthage/Carthage/"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"></a>
<a href="http://cocoadocs.org/"><img src="https://img.shields.io/cocoapods/v/Keldeo.svg?style=flat"></a>
</p>

A lightweight logging library written in Swift.

## Requirements

Swift 5.0, iOS 12.0

## Installation

CocoaPods, Carthage, Swift Package Manager

## Examples

1. Add loggers
```swift
let formatter = AlligatorFormatter() // Your custom Formatter

// Add Xcode Console logger
let consoleLogger = ConsoleLogger(level: .debug, formatter: formatter)
Logger.shared.add(AnyLogger(consoleLogger))

// Add File logger
let fileManager = DefaultFileManager() // Your custom FileManager
if let fileLogger = FileLogger(level: .info, formatter: formatter, fileManager: fileManager) {
    Logger.shared.add(AnyLogger(fileLogger))
}

// Or maybe you want to use Apple Unified Logging system (OSLog)
{ 
    let osLogger = OSLogger(level: .info, formatter: OSLogFormatter(), log: .default)
    Logger.shared.add(AnyLogger(consoleLogger))
}
```

2. Log message

```swift
Log.i("Keldeo is a lightweight logging library written in Swift.") // info level
// Xcode Console ouput: 🐊 2018-08-23 23:33:33.3333 [ViewController.swift:23] viewDidLoad() | Keldeo is a lightweight logging library written in Swift.
// /caches/com.xspyhack.logs/2018-08-23-23-33-33.log output: 🐊 2018-08-23 23:33:33.3333 [ViewController.swift:23] viewDidLoad() | Keldeo is a lightweight logging library written in Swift.

Log.d("This is a debug message")
Log.w("This is a warning message")
Log.e("This is an error message")
```

## Advanced

### Creating Custom Logger

```swift
public struct WebLogger: Logging {
    public var formatter: Formatter
    public var level: Level

    public var name: String {
        return "com.xspyhack.WebLogger"
    }

    public init(level: Level = .info, formatter: Formatter) {
        self.level = level
        self.formatter = formatter
    }

    public func log(message: Message) {
        // Send to web
    }

    public func start() {
        // Setup connection
    }

    public func teardown() {
        // Close connection
    }
}
```

The Logger needs conform to protocol `Hashable`.

```swift
extension WebLogger: Hashable {
    public static func == (lhs: WebLogger, rhs: WebLogger) -> Bool {
        return lhs.level == rhs.level && lhs.name == rhs.name
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(level)
    }
}
```

### Formatting Log Messages

```swift
struct OSLogFormatter: Keldeo.Formatter {
    func format(message: Message) -> String {
        var string = ""

        let level: String
        switch message.level {
        case .error:
            level = "❌"
        case .warning:
            level = "⚠️"
        case .info:
            level = "🐊"
        case .debug:
            level = "💊"
        case .off:
            level = ""
        }
        string += "\(level) "

        let file = (message.file as NSString).lastPathComponent
        string += "[\(file):\(message.line)] \(message.function) "

        string += "| \(message.message)"

        return string
    }
}
```

### Log Levels

There are several log levels employed by Keldeo, which correspond to the different types of messages the logger may need to process.

```swift
enum Level {
    case off, error, warning, info, debug
}
```

```swift
let consoleLogger = ConsoleLogger(level: .debug, formatter: formatter) // can capture all level log message
let osLogger = OSLogger(level: .info, formatter: OSLogFormatter(), log: .default) // can capture `error`, `warning` and `info` level log message
let fileLogger = FileLogger(level: .error, formatter: formatter, fileManager: fileManager) // only capture `error` level log message
let disabledLogger = ConsoleLogger(level: .off, formatter: formatter) // won't capture any log message

Log.d("This message should be processed by `consoleLogger`")
Log.i("This message should be processed by `consoleLogger` and `osLogger`")
Log.w("This message should be processed by `consoleLogger` and `osLogger`")
Log.e("This message should be processed by `consoleLogger`, `osLogger` and `fileLogger`")

```

## License

Keldeo is available under the MIT License. See the LICENSE file for more info.
