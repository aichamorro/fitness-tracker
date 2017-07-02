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

protocol IFitnessInfo {
    var weight: Double { get }
    var height: UInt { get }
    var bodyFatPercentage: Double { get }
    var musclePercentage: Double { get }
    var waterPercentage: Double { get }
    var date: NSDate? { get }
}

func ==<T: IFitnessInfo>(lhs: T, rhs: T) -> Bool {
    if lhs.weight != rhs.weight {
        return false
    }
    
    if lhs.height != lhs.height {
        return false
    }
    
    if lhs.bodyFatPercentage != rhs.bodyFatPercentage {
        return false
    }
    
    if lhs.musclePercentage != rhs.musclePercentage {
        return false
    }
    
    if lhs.waterPercentage != rhs.waterPercentage {
        return false
    }
    
    if lhs.date != rhs.date {
        return false
    }
    
    return true
}

struct FitnessInfo: IFitnessInfo {
    let weight: Double
    let height: UInt
    let bodyFatPercentage: Double
    let musclePercentage: Double
    let waterPercentage: Double
    let date: NSDate?
    
    init(weight: Double, height: UInt, bodyFatPercentage: Double, musclePercentage: Double, waterPercentage: Double, date: NSDate? = nil) {
        self.weight = weight
        self.height = height
        self.bodyFatPercentage = bodyFatPercentage
        self.musclePercentage = musclePercentage
        self.waterPercentage = waterPercentage
        self.date = date
    }
}

extension FitnessInfo {
    static var empty: IFitnessInfo = {
        return FitnessInfo(weight: 0, height: 0, bodyFatPercentage: 0, musclePercentage: 0, waterPercentage: 0)
    }()
}

extension IFitnessInfo {
    var bodyFatWeight: Double {
        return Double(weight) * (bodyFatPercentage/100)
    }
    
    var leanBodyWeight: Double {
        return Double(weight) - bodyFatWeight
    }
    
    var muscleWeight: Double {
        return Double(weight) * (musclePercentage/100)
    }
    
    var waterWeight: Double {
        return Double(weight) * (waterPercentage/100)
    }
    
    var bmi: Double {
        let denominator = Double(height * height)/10000
        let numerator = Double(weight)
        
        return numerator/denominator
    }    
}


enum BMIRating {
    case underweight
    case healthyweight
    case overweight
    case obese
    case severelyObese
    case morbidlyObese
    case superObese
    
    var localizedDescription: String {
        switch self {
        case .underweight: return LocalizableStrings.Measures.BmiRating.underweight()
        case .healthyweight: return LocalizableStrings.Measures.BmiRating.healthyweight()
        case .overweight: return LocalizableStrings.Measures.BmiRating.overweight()
        case .obese: return LocalizableStrings.Measures.BmiRating.obese()
        case .severelyObese: return LocalizableStrings.Measures.BmiRating.severylyObese()
        case .morbidlyObese: return LocalizableStrings.Measures.BmiRating.morbidlyObese()
        case .superObese: return LocalizableStrings.Measures.BmiRating.superObese()
        }
    }
}

extension BMIRating {
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
