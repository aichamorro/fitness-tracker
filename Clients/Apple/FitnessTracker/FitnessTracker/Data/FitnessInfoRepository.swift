//
//  FitnessInfoRepository.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 20/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

protocol IFitnessInfoRepository {
    func getLastRecord(success: (IFitnessInfo) -> Void, error: (Error) -> Void)
    mutating func storeRecord(record: IFitnessInfo, success: (IFitnessInfo) -> Void, error: (Error) -> Void)
}

protocol IRxFitnessInfoRepository: IFitnessLogRepository {
    var rx_lastRecord: Observable<IFitnessInfo> { get }
}

struct MockFitnessInfoRepository: IFitnessInfoRepository {
    var mockLastRecord: IFitnessInfo
    
    func getLastRecord(success: (IFitnessInfo) -> Void, error: (Error) -> Void) {
        success(mockLastRecord)
    }
    
    mutating func storeRecord(record: IFitnessInfo, success: (IFitnessInfo) -> Void, error: (Error) -> Void) {
        mockLastRecord = record
        
        success(mockLastRecord)
    }
}

