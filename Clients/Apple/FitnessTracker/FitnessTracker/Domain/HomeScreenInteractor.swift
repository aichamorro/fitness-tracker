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
    var rx_currentRecord: Observable<IFitnessInfo> { get }
    
    func loadLatest()
}

struct HomeScreenInteractor: IHomeScreenInteractor {
    let repository: IFitnessInfoRepository
    let currentRecord = PublishSubject<IFitnessInfo>()
    
    var rx_currentRecord: Observable<IFitnessInfo> {
        return repository.rx_latest
    }
    
    func loadLatest() {
        repository.loadLatest()
    }
}
