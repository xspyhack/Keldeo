//
//  FileLogger.swift
//  Logger
//
//  Created by bl4ckra1sond3tre on 2018/8/21.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import Foundation

/// A logger that logs to a file.
public struct FileLogger: Logging {

    public var formatter: Formatter

    public var level: Level

    private let fileHandle: FileHandle

    private let fileManager: LogFileManager

    public var name: String {
        return "com.xspyhack.fileLogger"
    }

    public init?(level: Level = .info, formatter: Formatter, fileManager: LogFileManager = DefaultFileManager()) {
        self.level = level
        self.formatter = formatter
        self.fileManager = fileManager
        guard let fileHandle = FileHandle(forWritingAtPath: fileManager.filePath()) else {
            return nil
        }
        self.fileHandle = fileHandle
    }

    public func log(message: Message) {
        let formattedMessage = formatter.format(message: message)

        guard let data = formattedMessage.data(using: .utf8) else {
            return
        }

        fileHandle.write(data)
    }

    public func flush() {
        fileHandle.synchronizeFile()
    }

    public func start() {
        setup()
    }

    public func teardown() {
        fileHandle.synchronizeFile()
        fileHandle.closeFile()
    }
}

extension FileLogger {

    private func roll() {

    }

    private func setup() {
        fileHandle.seekToEndOfFile()

        // Here we are monitoring the log file. In case if it would be deleted ormoved
        // somewhere we want to roll it and use a new one.
    }
}

extension FileLogger: Hashable {
    public static func == (lhs: FileLogger, rhs: FileLogger) -> Bool {
        return lhs.level == rhs.level && lhs.name == rhs.name
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(level)
    }
}

/// File manager to roll file or do something with the log file
public protocol LogFileManager {

    /// Log files directory
    var directory: String { get }

    /// File path for current session
    func filePath() -> String
}

public struct DefaultFileManager: LogFileManager {

    public var directory: String

    public var maxFilePeriodInSecond: Double = 0

    private let fileManager = FileManager()

    private let queue = DispatchQueue(label: "com.xspyhack.fileManager.queue")

    public func filePath() -> String {
        // return a new file path for file logging
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        return directory + "/\(formatter.string(from: date)).log"
    }

    public init() {
        let cachesDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let directory = cachesDirectory + "/com.xspyhack.logs"
        self.init(directory: directory)
    }

    public init(directory: String) {
        self.directory = directory

        // create file directory if not exists
        if !fileManager.fileExists(atPath: directory) {
            try? fileManager.createDirectory(atPath: directory,
                                             withIntermediateDirectories: true,
                                             attributes: nil)
        }

        // clean old log files in background
        deleteInBackground()
    }

    private func deleteInBackground() {
        queue.async {
            let (urlsToDelete, files) = self.travelFiles()

            for fileURL in urlsToDelete {
                do {
                    try self.fileManager.removeItem(at: fileURL)
                } catch _ { }
            }
        }
    }

    private func travelFiles() -> (urlsToDelete: [URL], cachedFiles: [URL: URLResourceValues]) {

        let directoryURL = URL(fileURLWithPath: directory)

        let resourceKeys: Set<URLResourceKey> = [.isDirectoryKey, .contentAccessDateKey, .totalFileAllocatedSizeKey]
        let expiredDate: Date? = (maxFilePeriodInSecond < 0) ? nil : Date(timeIntervalSinceNow: -maxFilePeriodInSecond)

        var files = [URL: URLResourceValues]()
        var urlsToDelete = [URL]()
        var diskCacheSize: UInt = 0

        for url in (try? fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: Array(resourceKeys), options: .skipsHiddenFiles)) ?? [] {

            do {
                let resourceValues = try url.resourceValues(forKeys: resourceKeys)
                // If it is a Directory. Continue to next file URL.
                if resourceValues.isDirectory == true {
                    continue
                }

                // If this file is expired, add it to URLsToDelete
                if let expiredDate = expiredDate,
                    let lastAccessData = resourceValues.contentAccessDate,
                    (lastAccessData as NSDate).laterDate(expiredDate) == expiredDate {
                    urlsToDelete.append(url)
                    continue
                }

                if let fileSize = resourceValues.totalFileAllocatedSize {
                    diskCacheSize += UInt(fileSize)
                    files[url] = resourceValues
                }
            } catch _ { }
        }

        return (urlsToDelete, files)
    }

    private func sortedFiles() {

    }
}
