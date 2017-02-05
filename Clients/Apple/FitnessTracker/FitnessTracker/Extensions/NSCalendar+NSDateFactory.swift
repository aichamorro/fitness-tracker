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
        
        let monday = self.date(byAdding: .day, value: -daysToPrevMondayFromDate(date: date), to: date as Date)!

        return self.date(bySettingHour: 0, minute: 0, second: 0, of: monday)!
    }
    
    private func daysToPrevMondayFromDate(date: NSDate) -> Int {
        let weekday = component(.weekday, from: date as Date)
        
        return (Int(DaysPerWeek) - (NSCalendarMondayWeekDay - weekday)) % Int(DaysPerWeek)
    }
    
    private func isDateInMonday(date: NSDate) -> Bool {
        return component(.weekday, from: date as Date) == 2
    }
    
    public func weekInterval(of date: NSDate) -> DateInterval? {
        let firstDayOfWeek = previousMonday(fromDate: date)
        
        return DateInterval(start: firstDayOfWeek, duration: SEC_PER_WEEK)
    }
    
    public func monthInterval(of date: NSDate) -> DateInterval? {
        return dateInterval(of: .month, for: date as Date)
    }
    
    public func yearInterval(of date: NSDate) -> DateInterval? {
        return dateInterval(of: .year, for: date as Date)
    }
}

extension Calendar {
    var now: Date {
        return Date()
    }
    
    var startOfToday: Date {
        return date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
    }
    
    var endOfToday: Date {
        return date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
    }
    
    func date(addingDays days: Int, to date: Date) -> Date {
        return self.date(byAdding: .day, value: days, to: date)!
    }
}

