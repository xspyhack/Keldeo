//
//  ViewController.swift
//  Alligator
//
//  Created by bl4ckra1sond3tre on 2018/8/25.
//  Copyright © 2018 blessingsoftware. All rights reserved.
//

import UIKit
import Keldeo

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        Log.d("Do any additional setup after loading the view, typically from a nib. This should't be log to file.")

        Log.i("View did load")

        Log.w("This is a warning message")

        Log.e("This is Log.e() message synchronously")
        
        print("This is print() message")

        NSLog("This is NSLog() message")

        DispatchQueue.concurrentPerform(iterations: 100) { index in
            Log.i("\(index)")
        }
    }
}

