//
//  FitnessInfo.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 13/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation

typealias Weight = UInt
typealias Height = UInt

public struct FitnessInfo {
    let weight: Weight
    let height: Height
    let bodyFatPercentage: Double
    let musclePercentage: Double
}

public extension FitnessInfo {
    var bodyFatWeight: Double {
        return Double(weight) * bodyFatPercentage
    }
    
    var leanBodyWeight: Double {
        return Double(weight) - bodyFatWeight
    }
    
    var muscleWeight: Double {
        return Double(weight) * musclePercentage
    }
    
    var bmi: Double {
        let denominator = Double(height * height)/10000
        let numerator = Double(weight)
        
        return numerator/denominator
    }    
}

public enum BMIRating {
    case underweight
    case healthyweight
    case overweight
    case obese
    case severelyObese
    case morbidlyObese
    case superObese
}

public extension BMIRating {
    static func `for`(bmi: Double) -> BMIRating {
        return DefaultBMIClassification(bmi)
    }
}


fileprivate typealias BMIClassification = (Double) -> BMIRating
fileprivate let DefaultBMIClassification: BMIClassification = { bmi in
    switch bmi {
    case 0..<18.5: return .underweight
    case 18.5..<25.0: return .healthyweight
    case 25.0..<30.0: return .overweight
    case 30.0..<35.0: return .obese
    case 35.0..<40.0: return .severelyObese
    case 40.0..<49.9: return .morbidlyObese
    default: return .superObese
    }
}
