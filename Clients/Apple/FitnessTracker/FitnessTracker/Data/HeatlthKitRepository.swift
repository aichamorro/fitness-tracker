//
//  HeatlthKitRepository.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro on 10/02/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation
import HealthKit

protocol IHealthKitRepository {
    func save(height: UInt, weight: Double, bodyFatPercentage: Double, leanBodyMass: Double, bmi: Double, date: Date)
}

final class HealthKitRepository: IHealthKitRepository {

    private let healthStore: HKHealthStore

    private var writeDataTypes: Set<HKSampleType> {
        let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass)!
        let heightType = HKObjectType.quantityType(forIdentifier: .height)!
        let bmiType = HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!
        let fatPercentageType = HKObjectType.quantityType(forIdentifier: .bodyFatPercentage)!
        let leanBodyMassType = HKObjectType.quantityType(forIdentifier: .leanBodyMass)!

        return Set(arrayLiteral: weightType, heightType, bmiType, fatPercentageType, leanBodyMassType)
    }

    init?() {
        guard HKHealthStore.isHealthDataAvailable() == true else {
            return nil
        }

        healthStore = HKHealthStore()
        healthStore.requestAuthorization(toShare: writeDataTypes, read: nil) { (success, error) in
            if !success {
                NSLog("You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: \(String(describing: error)). If you're using a simulator, try it on a device.")

                return
            }
        }
    }

    internal func save(height: UInt, weight: Double, bodyFatPercentage: Double, leanBodyMass: Double, bmi: Double, date: Date = Date()) {
        let height = HKQuantitySample(type: HKQuantityType.quantityType(forIdentifier: .height)!,
                                      quantity: HKQuantity(unit: HKUnit.meter(), doubleValue: Double(height)/100),
                                      start: date,
                                      end: date)

        let weight = HKQuantitySample(type: HKQuantityType.quantityType(forIdentifier: .bodyMass)!,
                                      quantity: HKQuantity(unit: HKUnit.gram(), doubleValue: weight * 1000),
                                      start: date, end: date)

        let bodyFat = HKQuantitySample(type: HKQuantityType.quantityType(forIdentifier: .bodyFatPercentage)!,
                                       quantity: HKQuantity(unit: HKUnit.percent(), doubleValue: bodyFatPercentage/100),
                                       start: date, end: date)

        let leanBodyMass = HKQuantitySample(type: HKQuantityType.quantityType(forIdentifier: .leanBodyMass)!,
                                     quantity: HKQuantity(unit: HKUnit.gram(), doubleValue: leanBodyMass*1000),
                                     start: date, end: date)

        let bmi = HKQuantitySample(type: HKQuantityType.quantityType(forIdentifier: .bodyMassIndex)!,
                                   quantity: HKQuantity(unit: HKUnit.count(), doubleValue: bmi),
                                   start: date, end: date)

        healthStore.save([height, weight, bodyFat, leanBodyMass, bmi]) { result, _ in
            if !result {
                NSLog("Something went wrong")
            }
        }
    }
}
