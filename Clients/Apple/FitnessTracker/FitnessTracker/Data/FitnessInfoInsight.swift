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
        return Int(after.height - before.height)
    }

    var weight: Double {
        return after.weight - before.weight
    }

    var musclePercentage: Double {
        return after.musclePercentage - before.musclePercentage
    }

    var bodyFatPercentage: Double {
        return after.bodyFatPercentage - before.bodyFatPercentage
    }

    var waterPercentage: Double {
        return after.waterPercentage - before.waterPercentage
    }

    var muscleWeight: Double {
        return after.muscleWeight - before.muscleWeight
    }

    var bodyFatWeight: Double {
        return after.bodyFatWeight - before.bodyFatWeight
    }

    var waterWeight: Double {
        return after.waterWeight - before.waterWeight
    }
}

struct FitnessInfoInsight {
    let reference: IFitnessInfo?
    let previousRecord: IFitnessInfo?
    let firstDayOfWeek: IFitnessInfo?
    let firstDayOfMonth: IFitnessInfo?
    let firstDayOfYear: IFitnessInfo?

    private var canComputeDayInsight: Bool {
        return previousRecord != nil && reference != nil
    }

    private var canComputeWeekInisght: Bool {
        return firstDayOfWeek != nil && reference != nil
    }

    private var canComputeMonthlyInsight: Bool {
        return firstDayOfMonth != nil && reference != nil
    }

    private var canComputeYearInsight: Bool {
        return firstDayOfYear != nil && reference != nil
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

    var yearInsight: IInsightInfo? {
        guard canComputeYearInsight else { return nil }

        return InsightInfo(before: firstDayOfYear!, after: reference!)
    }
}

extension FitnessInfoInsight {
    static var empty: FitnessInfoInsight {
        return FitnessInfoInsight(reference: nil, previousRecord: nil, firstDayOfWeek: nil, firstDayOfMonth: nil, firstDayOfYear: nil)
    }
}
