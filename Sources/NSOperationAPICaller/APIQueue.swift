//
//  File.swift
//  
//
//  Created by Sandeep on 10/05/21.
//

import Foundation

public class APICallQueue: OperationQueue {
    static var shared = APICallQueue()
    override init() {
        super.init()
        maxConcurrentOperationCount = 3
    }
}
