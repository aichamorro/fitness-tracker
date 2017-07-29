//
//  ShowPreviousLatestResultInteractor.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro on 08/02/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

typealias IFindPreviousLatestRecord = AnyInteractor<Void, IFitnessInfo>
final class FindPreviousLatestRecord: IFindPreviousLatestRecord {
    init(repository: IFitnessInfoRepository) {
        super.init { () -> Observable<IFitnessInfo> in
            return repository.rx_findLatest(numberOfRecords: 2).flatMap { info in
                Observable.create { observer in
                    observer.onNext(info.count == 2 ? info[1] : FitnessInfo.empty)
                    observer.onCompleted()

                    return Disposables.create()
                }
            }
        }
    }
}
