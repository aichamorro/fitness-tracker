//
//  HomeScreenInteractor.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 20/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

protocol IHomeScreenInteractor {
    var rx_latestRecordUpdate: Observable<Void> { get }
    
    func rx_findLatest() -> Observable<IFitnessInfo>
}

final class HomeScreenInteractor: IHomeScreenInteractor {
    let repository: IFitnessInfoRepository
    
    var rx_latestRecordUpdate: Observable<Void> {
        return repository.rx_updated
    }
    
    init(repository: IFitnessInfoRepository) {
        self.repository = repository
    }
    
    func rx_findLatest() -> Observable<IFitnessInfo> {
        let takeFirstResult: ([IFitnessInfo]) -> Observable<IFitnessInfo> = { result in
            guard let latest = result.first else { return Observable.just(FitnessInfo.empty) }
            
            return Observable.just(latest)
        }
        
        return repository
            .findLatest(numberOfRecords: 1)
            .flatMap(takeFirstResult)
    }
}
