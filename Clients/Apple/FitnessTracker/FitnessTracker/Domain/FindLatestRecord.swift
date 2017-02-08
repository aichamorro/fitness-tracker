//
//  LatestRecordInteractor.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 20/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

protocol IFindLatestRecord {
    func rx_find() -> Observable<IFitnessInfo>
}

final class FindLatestRecord: IFindLatestRecord {
    let repository: IFitnessInfoRepository
    
    init(repository: IFitnessInfoRepository) {
        self.repository = repository
    }
    
    func rx_find() -> Observable<IFitnessInfo> {
        let takeFirstResult: ([IFitnessInfo]) -> Observable<IFitnessInfo> = { result in
            guard let latest = result.first else { return Observable.just(FitnessInfo.empty) }
            
            return Observable.just(latest)
        }
        
        return repository
            .rx_findLatest(numberOfRecords: 1)
            .flatMap(takeFirstResult)
    }
}