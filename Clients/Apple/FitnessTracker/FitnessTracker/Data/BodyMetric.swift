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
    var description: String {
        switch self {
        case .height: return "Height"
        case .weight: return "Weight"
        case .bodyFatPercentage: return "Body Fat (%)"
        case .musclePercentage: return "Muscle (%)"
        case .waterPercentage: return "Water (%)"
        case .bodyFatWeight: return "Body Fat (Kg)"
        case .muscleWeight: return "Muscle (Kg)"
        case .waterWeight: return "Water (Kg)"
        case .leanBodyWeight: return "Lean Body Weight (Kg)"
        case .bmi: return "BMI"
        }
    }
}
