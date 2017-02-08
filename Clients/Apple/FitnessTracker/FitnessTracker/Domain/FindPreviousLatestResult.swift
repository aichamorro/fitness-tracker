//
//  ShowPreviousLatestResultInteractor.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro on 08/02/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

protocol IFindPreviousLatestRecord {
    func rx_find() -> Observable<IFitnessInfo>
}

class FindPreviousLatestRecord: IFindPreviousLatestRecord {
    let repository: IFitnessInfoRepository
    
    init(repository: IFitnessInfoRepository) {
        self.repository = repository
    }
    
    func rx_find() -> Observable<IFitnessInfo> {
        return repository.rx_findLatest(numberOfRecords: 2).flatMap { info in
            Observable.create { observer in
                observer.onNext(info.count == 2 ? info[1] : FitnessInfo.empty)
                observer.onCompleted()
                
                return Disposables.create()
            }
        }
    }
}
