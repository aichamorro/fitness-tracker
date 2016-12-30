//
//  FitnessInfo+Operators.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 23/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation

func ==(lhs: IFitnessInfo, rhs: IFitnessInfo) -> Bool {
    if lhs.height != rhs.height { return false }
    if lhs.weight != rhs.weight { return false }
    
    let errorTolerance = 0.000001
    if abs(lhs.bodyFatPercentage - rhs.bodyFatPercentage) >= errorTolerance { return false }
    if abs(lhs.musclePercentage - rhs.musclePercentage) >= errorTolerance { return false }
    
    return true
}

func -(lhs: IFitnessInfo, rhs: IFitnessInfo) -> IFitnessInfo {
    return FitnessInfo(weight: lhs.weight - rhs.weight,
                       height: lhs.height - lhs.height,
                       bodyFatPercentage: lhs.bodyFatPercentage - rhs.bodyFatPercentage,
                       musclePercentage: lhs.musclePercentage - rhs.musclePercentage,
                       waterPercentage: lhs.waterPercentage - rhs.waterPercentage)
}
