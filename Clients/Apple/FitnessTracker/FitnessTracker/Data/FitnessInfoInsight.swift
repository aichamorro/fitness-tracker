//
//  FitnessInfoInsight.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 01/01/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation

protocol IInsightInfo {
    var height: Int { get }
    var weight: Double { get }
    var musclePercentage: Double { get }
    var bodyFatPercentage: Double { get }
    var waterPercentage: Double { get }
    var muscleWeight: Double { get }
    var bodyFatWeight: Double { get }
    var waterWeight: Double { get }
}

struct InsightInfo {
    let before: IFitnessInfo
    let after: IFitnessInfo
}

extension InsightInfo: IInsightInfo {
    var height: Int {
        return Int(before.height - after.height)
    }
    
    var weight: Double {
        return before.weight - after.weight
    }
    
    var musclePercentage: Double {
        return before.musclePercentage - after.musclePercentage
    }
    
    var bodyFatPercentage: Double {
        return before.bodyFatPercentage - after.bodyFatPercentage
    }
    
    var waterPercentage: Double {
        return before.waterPercentage - after.waterPercentage
    }
    
    var muscleWeight: Double {
        return before.muscleWeight - after.muscleWeight
    }
    
    var bodyFatWeight: Double {
        return before.bodyFatWeight - after.bodyFatWeight
    }
    
    var waterWeight: Double {
        return before.waterWeight - after.waterWeight
    }
}

struct FitnessInfoInsight {
    let reference: IFitnessInfo?
    let previousRecord: IFitnessInfo?
    let firstDayOfWeek: IFitnessInfo?
    let firstDayOfMonth: IFitnessInfo?
    
    private var canComputeDayInsight: Bool {
        return previousRecord != nil && reference != nil
    }
    
    private var canComputeWeekInisght: Bool {
        return firstDayOfWeek != nil && reference != nil
    }
    
    private var canComputeMonthlyInsight: Bool {
        return firstDayOfMonth != nil && reference != nil
    }
    
    var dayInsight: IInsightInfo? {
        guard canComputeDayInsight else { return nil }
        
        return InsightInfo(before: previousRecord!, after: reference!)
    }
    
    var weekInsight: IInsightInfo? {
        guard canComputeWeekInisght else { return nil }
        
        return InsightInfo(before: firstDayOfWeek!, after: reference!)
    }
    
    var monthInsight: IInsightInfo? {
        guard canComputeMonthlyInsight else { return nil }
        
        return InsightInfo(before: firstDayOfMonth!, after: reference!)
    }
}

extension FitnessInfoInsight {
    static var empty: FitnessInfoInsight {
        return FitnessInfoInsight(reference: nil, previousRecord: nil, firstDayOfWeek: nil, firstDayOfMonth: nil)
    }
}
