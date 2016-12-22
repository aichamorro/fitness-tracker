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
    var rx_latest: Observable<IFitnessInfo> { get }
    
    func loadLatest()
    func save(record: IFitnessInfo) -> Observable<IFitnessInfo>
}

class MockFitnessInfoRepository: IFitnessInfoRepository {
    private let rx_latestSubject = PublishSubject<IFitnessInfo>()
    
    var mockLastRecord: IFitnessInfo!

    init(mockLastRecord: IFitnessInfo) {
        self.mockLastRecord = mockLastRecord
    }
    
    var rx_latest: Observable<IFitnessInfo> {
        return rx_latestSubject.asObservable()
    }
    
    func loadLatest() {
        rx_latestSubject.onNext(mockLastRecord)
    }
    
    func save(record: IFitnessInfo) -> Observable<IFitnessInfo> {
        mockLastRecord = record
     
        return Observable.just(mockLastRecord)
    }
}

