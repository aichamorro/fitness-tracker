//
//  InsightsInteractor.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro on 08/02/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

protocol IFindInsights {
    func rx_insights() -> Observable<FitnessInfoInsight>
}

class FindInsights: IFindInsights {
    let repository: IFitnessInfoRepository
    
    init(repository: IFitnessInfoRepository) {
        self.repository = repository
    }
    
    func rx_insights() -> Observable<FitnessInfoInsight> {
        return Observable.create { observer in
            let latestRecords = self.repository.findLatest(numberOfRecords: 2)
            guard latestRecords.count == 2 else {
                observer.onNext(FitnessInfoInsight.empty)
                
                return Disposables.create {}
            }
            
            let latestRecordDate = latestRecords.first!.date!
            let firstDayOfWeek = self.repository.findFirstOfWeek(ofDay: latestRecordDate)
            let firstDayOfMonth = self.repository.findFirstOfMonth(ofDay: latestRecordDate)
            let firstDayOfYear = self.repository.findFirstOfYear(ofDay: latestRecordDate)
            
            observer.onNext(FitnessInfoInsight(reference: latestRecords[0], previousRecord: latestRecords[1], firstDayOfWeek: firstDayOfWeek, firstDayOfMonth: firstDayOfMonth, firstDayOfYear: firstDayOfYear))
            
            return Disposables.create {}
        }
    }
}
