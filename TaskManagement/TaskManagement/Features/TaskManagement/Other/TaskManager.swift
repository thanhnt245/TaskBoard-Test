//
//  TaskManager.swift
//  TaskManagement
//
//  Created by Thanh Nguyen on 8/16/20.
//  Copyright © 2020 Thanh Nguyen. All rights reserved.
//

import Foundation

class TaskManager {
    static let shared = TaskManager()
    
    var timeSpan: Int = 15
    
    var users: [User] = []
    init() {
        // Default work start from 8 AM
        let workStartTime = 8 * 60
        // Creat default 10 users
        for i in 1...10 {
            users.append(AppUser(name: "User \(i)", tasks: [AppDailyTask(startTime: workStartTime + timeSpan * i)]))
        }
    }
}
