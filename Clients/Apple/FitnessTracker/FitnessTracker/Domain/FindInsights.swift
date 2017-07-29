//
//  InsightsInteractor.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro on 08/02/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

typealias IFindInsights = AnyInteractor<Void, FitnessInfoInsight>

class FindInsights: IFindInsights {
    init(repository: IFitnessInfoRepository) {
        super.init { () -> Observable<FitnessInfoInsight> in
            return Observable.create { observer in
                let latestRecords = repository.findLatest(numberOfRecords: 2)
                guard latestRecords.count == 2 else {
                    observer.onNext(FitnessInfoInsight.empty)

                    return Disposables.create {}
                }

                let latestRecordDate = latestRecords.first!.date!
                let firstDayOfWeek = repository.findFirstOfWeek(ofDay: latestRecordDate)
                let firstDayOfMonth = repository.findFirstOfMonth(ofDay: latestRecordDate)
                let firstDayOfYear = repository.findFirstOfYear(ofDay: latestRecordDate)

                observer.onNext(FitnessInfoInsight(reference: latestRecords[0],
                                                   previousRecord: latestRecords[1],
                                                   firstDayOfWeek: firstDayOfWeek,
                                                   firstDayOfMonth: firstDayOfMonth,
                                                   firstDayOfYear: firstDayOfYear))

                return Disposables.create {}
            }
        }
    }
}
