//
//  ModelProtocols.swift
//  TaskManagement
//
//  Created by Thanh Nguyen on 8/15/20.
//  Copyright © 2020 Thanh Nguyen. All rights reserved.
//

import Foundation

protocol User {
    var name: String { get }
    var tasks: [DailyTask] { get set } 
}

protocol DailyTask {
    var startTime: Int { get set }
    var description: String { get set }
}

class AppUser: User {
    var name: String = ""
    var tasks: [DailyTask] = []
    
    init(name: String, tasks: [DailyTask]) {
        self.name = name
        self.tasks = tasks
    }
}

class AppDailyTask: DailyTask {
    var startTime: Int = 0
    var description: String = ""
    
    init(startTime: Int, description: String? = nil) {
        self.startTime = startTime
        if let theDescription = description {
            self.description = theDescription
        } else {
            let hour = startTime / 60
            let minute = startTime % 60
            self.description = String(format: "Task at %02d:%02d", hour, minute)
        }
    }
}
