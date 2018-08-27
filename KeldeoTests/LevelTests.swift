//
//  LevelTests.swift
//  KeldeoTests
//
//  Created by bl4ckra1sond3tre on 2018/8/25.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import XCTest
@testable import Keldeo

class LevelTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        XCTAssertEqual(Flag.error.rawValue, Level.error.rawValue)
        XCTAssertEqual(Level.error.rawValue | Flag.warning.rawValue, Level.warning.rawValue)
        XCTAssertEqual(Level.warning.rawValue | Flag.info.rawValue, Level.info.rawValue)
        XCTAssertEqual(Level.info.rawValue | Flag.debug.rawValue, Level.debug.rawValue)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
