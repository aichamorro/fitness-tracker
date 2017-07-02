//
//  BodyMetric.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro on 23/01/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation

enum BodyMetric: String {
    case height
    case weight
    case bodyFatPercentage
    case musclePercentage
    case waterPercentage
    case bodyFatWeight
    case muscleWeight
    case waterWeight
    case leanBodyWeight
    case bmi
}

extension BodyMetric {
    var name: String {
        switch self {
        case .height: return LocalizableStrings.Measures.BodyMetrics.height()
        case .weight: return LocalizableStrings.Measures.BodyMetrics.weight()
        case .bodyFatWeight: fallthrough
        case .bodyFatPercentage: return LocalizableStrings.Measures.BodyMetrics.bodyFat()
        case .musclePercentage: fallthrough
        case .muscleWeight: return LocalizableStrings.Measures.BodyMetrics.muscle()
        case .waterPercentage: fallthrough
        case .waterWeight: return LocalizableStrings.Measures.BodyMetrics.water()
        case .leanBodyWeight: return LocalizableStrings.Measures.BodyMetrics.leanBodyWeight()
        case .bmi: return LocalizableStrings.Measures.BodyMetrics.bmi()
        }
    }
    
    var description: String {
        switch self {
        case .height: return "\(self.name) (\(LocalizableStrings.Measures.BodyMetrics.Units.height()))"
        case .weight: return "\(self.name) (\(LocalizableStrings.Measures.BodyMetrics.Units.weight()))"
        case .bodyFatPercentage: fallthrough
        case .musclePercentage: fallthrough
        case .waterPercentage: return "\(self.name) (\(LocalizableStrings.Measures.BodyMetrics.Units.percentage()))"
        case .bodyFatWeight: fallthrough
        case .muscleWeight: fallthrough
        case .waterWeight: fallthrough
        case .leanBodyWeight: return "\(self.name) (\(LocalizableStrings.Measures.BodyMetrics.Units.weight()))"
        case .bmi: return self.name
        }
    }
}
