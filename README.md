# Keldeo
A lightweight logging library written in Swift.

## Requirements

Swift 4.2, iOS 12.0

## Examples

1. Add loggers
```swift
let formatter = AlligatorFormatter() // Your custom Formatter

// Add Xcode Console logger
let consoleLogger = ConsoleLogger(level: .debug, formatter: formatter)
Keldeo.shared.add(AnyLogger(consoleLogger))

// Add File logger
let fileManager = DefaultFileManager() // Your custom FileManager
if let fileLogger = FileLogger(level: .info, formatter: formatter, fileManager: fileManager) {
    Keldeo.shared.add(AnyLogger(fileLogger))
}
```

2. Log message

```swift
Log.i("Keldeo is a lightweight logging library written in Swift.")
// Xcode Console ouput: 🐊 2018-08-23 23:33:33.3333 [ViewController.swift:23] viewDidLoad() | Keldeo is a lightweight logging library written in Swift.
// /caches/com.xspyhack.logs/2018-08-23-23-33-33.log output: 🐊 2018-08-23 23:33:33.3333 [ViewController.swift:23] viewDidLoad() | Keldeo is a lightweight logging library written in Swift.
```

## License

Keldeo is available under the MIT License. See the LICENSE file for more info.