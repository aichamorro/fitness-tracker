//
//  FitnessLogRepository.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 14/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation

public protocol IFitnessLogRepository {
    func get(byDate: TimeInterval) -> StoredFitnessInfo?
    mutating func save(date: TimeInterval, record: IFitnessInfo) -> StoredFitnessInfo?
    mutating func delete(record: StoredFitnessInfo) -> StoredFitnessInfo?
}

public struct StoredFitnessInfo: IFitnessInfo {
    let date: TimeInterval
    let fitnessInfo: IFitnessInfo
    
    public var weight: Double {
        return fitnessInfo.weight
    }
    
    public var height: UInt {
        return fitnessInfo.height
    }
    
    public var bodyFatPercentage: Double {
        return fitnessInfo.bodyFatPercentage
    }
    
    public var musclePercentage: Double {
        return fitnessInfo.musclePercentage
    }
}

public struct FitnessLogRepository: IFitnessLogRepository {
    private var data = [TimeInterval:StoredFitnessInfo]()
    
    mutating public func save(date: TimeInterval, record: IFitnessInfo) -> StoredFitnessInfo? {
        data[date] = StoredFitnessInfo(date: date, fitnessInfo: record)
        
        return data[date]
    }
    
    mutating public func delete(record: StoredFitnessInfo) -> StoredFitnessInfo? {
        guard let stored = data[record.date] else { return nil }
        
        data[record.date] = nil
        
        return stored
    }
    
    public func get(byDate date: TimeInterval) -> StoredFitnessInfo? {
        return data[date]
    }
}
