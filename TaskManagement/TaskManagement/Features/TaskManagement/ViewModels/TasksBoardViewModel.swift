//
//  TasksBoardViewModel.swift
//  TaskManagement
//
//  Created by Thanh Nguyen on 8/16/20.
//  Copyright © 2020 Thanh Nguyen. All rights reserved.
//

import Foundation

final class TasksBoardViewModel {
    var users: [User] = []
    var timeSpan: Int = 15 // 15 minutes
    var workingDayStartTime: Int = 8 * 60 // 8AM
    var workingDayEndTime: Int = 17 * 60 // 5PM
    
    var timeSlots: [Int] = []
    var timeSlotsString: [String] = []
    
    func reCalculate() {
        timeSlots.removeAll()
        timeSlotsString.removeAll()
        var nextTime = workingDayStartTime
        while nextTime < workingDayEndTime {
            timeSlots.append(nextTime)
            let hour = nextTime / 60
            let minute = nextTime % 60
            timeSlotsString.append(String(format: "%02d:%02d", hour, minute))
            nextTime += timeSpan
        }
    }
    
    func getTaskForUser(_ user: User, time: Int) -> DailyTask? {
        return user.tasks.first(where: {$0.startTime >= time && $0.startTime < (time + timeSpan)})
    }
}
