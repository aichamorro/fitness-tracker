//
//  InsightsVIP.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 01/01/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

protocol IInsightsView {
    
}

protocol IInsightsInteractor {
    func rx_getInsights() -> Observable<FitnessInfoInsight>
}

class InsightsInteractor: IInsightsInteractor {
    let repository: IFitnessInfoRepository
    
    init(repository: IFitnessInfoRepository) {
        self.repository = repository
    }
    
    func rx_getInsights() -> Observable<FitnessInfoInsight> {
        return self.repository.rx_findLatest(numberOfRecords: 2)
            .flatMap { insights -> Observable<FitnessInfoInsight> in
                guard insights.count == 2 else { return Observable.just(FitnessInfoInsight.empty) }
                
                let weekOfDate = self.repository.findWeek(ofDay: insights.first!.date!)
                
                return Observable.just(FitnessInfoInsight(reference: insights[0], previousRecord: insights[1], firstDayOfWeek: weekOfDate.first, firstDayOfMonth: nil))
            }
    }
    
}

typealias IInsightsPresenter = (IInsightsInteractor, IInsightsView, DisposeBag) -> Void
let InsightsPresenter: IInsightsPresenter = { interactor, view, disposeBag in }
