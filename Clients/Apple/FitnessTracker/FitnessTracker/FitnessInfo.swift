//
//  FitnessInfo.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 13/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation

typealias Weight = Double
typealias Height = UInt

public protocol IFitnessInfo {
    var weight: Double { get }
    var height: UInt { get }
    var bodyFatPercentage: Double { get }
    var musclePercentage: Double { get }
    var date: NSDate? { get }
}

public struct FitnessInfo: IFitnessInfo {
    public let weight: Double
    public let height: UInt
    public let bodyFatPercentage: Double
    public let musclePercentage: Double
    public let date: NSDate? = nil
}

public extension FitnessInfo {
    static var empty: IFitnessInfo = {
        return FitnessInfo(weight: 0, height: 0, bodyFatPercentage: 0, musclePercentage: 0)
    }()
}

public extension IFitnessInfo {
    var bodyFatWeight: Double {
        return Double(weight) * (bodyFatPercentage/100)
    }
    
    var leanBodyWeight: Double {
        return Double(weight) - bodyFatWeight
    }
    
    var muscleWeight: Double {
        return Double(weight) * (musclePercentage/100)
    }
    
    var bmi: Double {
        let denominator = Double(height * height)/10000
        let numerator = Double(weight)
        
        return numerator/denominator
    }    
}


public enum BMIRating: String {
    case underweight = "Underweight"
    case healthyweight = "Healthy weight"
    case overweight = "Overweight"
    case obese = "Obese"
    case severelyObese = "Severy obese"
    case morbidlyObese = "Morbidly obese"
    case superObese = "Super obese"
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
