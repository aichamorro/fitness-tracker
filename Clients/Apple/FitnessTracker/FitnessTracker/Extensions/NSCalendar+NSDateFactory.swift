//
//  NSCalendar+NSDateFactory.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 02/01/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation

let SEC_PER_WEEK: TimeInterval = 7 * 24 * 60 * 60

private let NSCalendarMondayWeekDay = 2
private let DaysPerWeek = 7
extension Calendar {
    public func previousMonday(fromDate date: NSDate) -> Date {
        guard !isDateInMonday(date: date) else {
            return date as Date
        }
        
        return self.date(byAdding: .day, value: -daysToPrevMondayFromDate(date: date), to: date as Date)!
    }
    
    private func daysToPrevMondayFromDate(date: NSDate) -> Int {
        let weekday = component(.weekday, from: date as Date)
        
        return (Int(DaysPerWeek) - (NSCalendarMondayWeekDay - weekday)) % Int(DaysPerWeek)
    }
    
    private func isDateInMonday(date: NSDate) -> Bool {
        return component(.weekday, from: date as Date) == 2
    }
}

