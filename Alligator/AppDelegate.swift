//
//  AppDelegate.swift
//  Alligator
//
//  Created by bl4ckra1sond3tre on 2018/8/25.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import UIKit
import Logger

struct AlligatorFormatter: LogFormatter {

    let dateFormatter: DateFormatter

    init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyy-MM-dd hh:mm:ss.SSSS"
    }

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

        let timestamp = dateFormatter.string(from: message.timestamp)
        string += "\(timestamp) "

        let file = (message.file as NSString).lastPathComponent
        string += "[\(file):\(message.line)] \(message.function) "

        string += "| \(message.message)"

        return string
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let formatter = AlligatorFormatter()

        let consoleLogger = ConsoleLogger(level: .debug, formatter: formatter)
        Logger.shared.add(AnyLogger(consoleLogger))

        let fileManager = DefaultFileManager()
        if let fileLogger = FileLogger(level: .info, formatter: formatter, fileManager: fileManager) {
            Logger.shared.add(AnyLogger(fileLogger))

            print("Log directory: \(fileManager.directory)")
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

