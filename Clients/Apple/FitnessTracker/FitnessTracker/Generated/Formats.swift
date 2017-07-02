//
//  Formats.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 02/07/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation

enum Formats {
    enum BodyMeasurements {
        enum WithUnit {
            static func weight(_ value: Double) -> String {
                return "\(BodyMeasurements.WithoutUnit.weight(value)) \(LocalizableStrings.Measures.BodyMetrics.Units.weight())"
            }
            
            static func bodyFatWeight(_ value: Double) -> String {
                return "\(BodyMeasurements.WithoutUnit.bodyFatWeight(value)) \(LocalizableStrings.Measures.BodyMetrics.Units.weight())"
            }
            
            static func muscleWeight(_ value: Double) -> String {
                return "\(BodyMeasurements.WithoutUnit.muscleWeight(value)) \(LocalizableStrings.Measures.BodyMetrics.Units.weight())"
            }
            
            static func waterWeight(_ value: Double) -> String {
                return "\(BodyMeasurements.WithoutUnit.waterWeight(value)) \(LocalizableStrings.Measures.BodyMetrics.Units.weight())"
            }
            
            static func leanBodyWeight(_ value: Double) -> String {
                return "\(BodyMeasurements.WithoutUnit.leanBodyWeight(value)) \(LocalizableStrings.Measures.BodyMetrics.Units.weight())"
            }
            
            static func waterPercentage(_ value: Double) -> String {
                return "\(BodyMeasurements.WithoutUnit.waterPercentage(value)) \(LocalizableStrings.Measures.BodyMetrics.Units.percentage())"
            }
            
            static func height(_ value: UInt) -> String {
                return "\(BodyMeasurements.WithoutUnit.height(value)) \(LocalizableStrings.Measures.BodyMetrics.Units.height())"
            }
            
            static func bodyFatPercentage(_ value: Double) -> String {
                return "\(BodyMeasurements.WithoutUnit.bodyFatPercentage(value)) \(LocalizableStrings.Measures.BodyMetrics.Units.percentage())"
            }
            
            static func musclePercentage(_ value: Double) -> String {
                return "\(BodyMeasurements.WithoutUnit.musclePercentage(value)) \(LocalizableStrings.Measures.BodyMetrics.Units.percentage())"
            }
            
            static func bmi(_ value: Double) -> String {
                return BodyMeasurements.WithoutUnit.bmi(value)
            }
        }
        enum WithoutUnit {
            static func weight(_ value: Double) -> String {
                return String(format: "%.2f", value)
            }
            
            static func bodyFatWeight(_ value: Double) -> String {
                return String(format: "%.2f", value)
            }
            
            static func muscleWeight(_ value: Double) -> String {
                return String(format: "%.2f", value)
            }
            
            static func waterWeight(_ value: Double) -> String {
                return String(format: "%.2f", value)
            }
            
            static func leanBodyWeight(_ value: Double) -> String {
                return String(format: "%.2f", value)
            }
            
            static func waterPercentage(_ value: Double) -> String {
                return String(format: "%.2f", value)
            }
            
            static func bodyFatPercentage(_ value: Double) -> String {
                return String(format: "%.2f", value)
            }
            
            static func musclePercentage(_ value: Double) -> String {
                return String(format: "%.2f", value)
            }
            
            static func height(_ value: UInt) -> String {
                return String(format: "%d", value)
            }
            
            static func bmi(_ value: Double) -> String {
                return String(format: "%.1f", value)
            }
    
        }
    }
}
