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

    public var formatter: LogFormatter

    public var level: Level

    private let fileHandle: FileHandle

    private let fileManager: LogFileManager

    public var name: String {
        return "com.xspyhack.FileLogger"
    }

    public init?(level: Level, formatter: LogFormatter, fileManager: LogFileManager = DefaultFileManager()) {
        self.level = level
        self.formatter = formatter
        self.fileManager = fileManager
        guard let fileHandle = FileHandle(forWritingAtPath: fileManager.filePath()) else {
            return nil
        }
        self.fileHandle = fileHandle
    }

    public func log(message: Message) {
        let formattedMessage = formatter.format(message: message) + "\n" // Fuck it

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

/// File manager to roll file or do something with the log file.
public protocol LogFileManager {

    /// Log files directory
    var directory: String { get }

    /// File path for current session
    func filePath() -> String
}

/// Default File Manager for File Logger
/// It will create a new file on each launch session.
public struct DefaultFileManager: LogFileManager {

    /// Log files directory
    public var directory: String

    /// The longest time duration in second of the log files being stored in disk.
    /// Defaults 1 week.
    public var maxFilePeriodInSecond: TimeInterval = 60 * 60 * 24 * 7

    /// Max log file size in bytes. Defaults no limit.
    public var maxFileSize: UInt = 0

    private let fileManager = FileManager()

    private let queue = DispatchQueue(label: "com.xspyhack.fileManager.queue")

    /// File path for current session
    public func filePath() -> String {
        // return a new file path for file logging
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-hh-mm-ss"
        let path = directory + "/\(formatter.string(from: date)).log"

        fileManager.createFile(atPath: path, contents: nil, attributes: nil)

        return path
    }

    public init() {
        let cachesDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let directory = cachesDirectory + "/com.xspyhack.logs"
        self.init(directory: directory)
    }

    /// Init with log files directory.
    ///
    /// - Parameter directory: disk file path for storing logs.
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

    /// Delete expired log files in background.
    /// Copy from https://github.com/onevcat/Kingfisher/blob/master/Sources/ImageCache.swift
    private func deleteInBackground() {
        queue.async {
            var (urlsToDelete, diskFileSize, files) = self.travelFiles()

            for fileURL in urlsToDelete {
                do {
                    try self.fileManager.removeItem(at: fileURL)
                } catch _ { }
            }

            if self.maxFileSize > 0 && diskFileSize > self.maxFileSize {
                let targetSize = self.maxFileSize / 2

                // Sort files by last modify date. We want to clean from the oldest files.
                let sortedFiles = files.keysSortedByValue {
                    resourceValue1, resourceValue2 -> Bool in

                    if let date1 = resourceValue1.contentAccessDate,
                        let date2 = resourceValue2.contentAccessDate {
                        return date1.compare(date2) == .orderedAscending
                    }

                    // Not valid date information. This should not happen. Just in case.
                    return true
                }

                for fileURL in sortedFiles {

                    do {
                        try self.fileManager.removeItem(at: fileURL)
                    } catch { }

                    if let fileSize = files[fileURL]?.totalFileAllocatedSize {
                        diskFileSize -= UInt(fileSize)
                    }

                    if diskFileSize < targetSize {
                        break
                    }
                }
            }
        }
    }

    private func travelFiles() -> (urlsToDelete: [URL], diskFileSize: UInt, files: [URL: URLResourceValues]) {

        let directoryURL = URL(fileURLWithPath: directory)

        let resourceKeys: Set<URLResourceKey> = [.isDirectoryKey, .contentAccessDateKey, .totalFileAllocatedSizeKey]
        let expiredDate: Date? = (maxFilePeriodInSecond < 0) ? nil : Date(timeIntervalSinceNow: -maxFilePeriodInSecond)

        var files = [URL: URLResourceValues]()
        var urlsToDelete = [URL]()
        var diskFileSize: UInt = 0

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
                    diskFileSize += UInt(fileSize)
                    files[url] = resourceValues
                }
            } catch _ { }
        }

        return (urlsToDelete, diskFileSize, files)
    }
}

extension Dictionary {
    func keysSortedByValue(_ isOrderedBefore: (Value, Value) -> Bool) -> [Key] {
        return Array(self).sorted{ isOrderedBefore($0.1, $1.1) }.map{ $0.0 }
    }
}
