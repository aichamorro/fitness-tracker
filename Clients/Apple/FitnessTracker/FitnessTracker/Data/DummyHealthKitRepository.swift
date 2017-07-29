//
//  DummyHealthKitRepository.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 29/07/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation

struct DummyHealthKitRepository: IHealthKitRepository {
    func save(height: UInt, weight: Double, bodyFatPercentage: Double, leanBodyMass: Double, bmi: Double, date: Date) {
        // do nothing
    }
}
