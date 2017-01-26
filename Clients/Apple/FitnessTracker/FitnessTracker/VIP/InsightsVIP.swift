//
//  InsightsVIP.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 01/01/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

typealias FitnessInfoInsightViewModel = (title: String, weight: Double, bodyFatWeight: Double, muscleWeight: Double, waterPercentage: Double)
protocol IInsightsView {
    var rx_insights: AnyObserver<[FitnessInfoInsightViewModel]> { get }
}

protocol IInsightsInteractor {
    func rx_getInsights() -> Observable<FitnessInfoInsight>
    var rx_latestRecordUpdated: Observable<Void> { get }
}

private extension Disposables {
    static var NoOpDisposable: Cancelable {
        return Disposables.create { }
    }
}

class InsightsInteractor: IInsightsInteractor {
    let repository: IFitnessInfoRepository
    
    init(repository: IFitnessInfoRepository) {
        self.repository = repository
    }
    
    func rx_getInsights() -> Observable<FitnessInfoInsight> {
        return Observable.create { observer in
            let latestRecords = self.repository.findLatest(numberOfRecords: 2)
            guard latestRecords.count == 2 else {
                observer.onNext(FitnessInfoInsight.empty)
                
                return Disposables.NoOpDisposable
            }
            
            let latestRecordDate = latestRecords.first!.date!
            let firstDayOfWeek = self.repository.findFirstOfWeek(ofDay: latestRecordDate)
            let firstDayOfMonth = self.repository.findFirstOfMonth(ofDay: latestRecordDate)
            let firstDayOfYear = self.repository.findFirstOfYear(ofDay: latestRecordDate)
            
            observer.onNext(FitnessInfoInsight(reference: latestRecords[0], previousRecord: latestRecords[1], firstDayOfWeek: firstDayOfWeek, firstDayOfMonth: firstDayOfMonth, firstDayOfYear: firstDayOfYear))
            
            return Disposables.NoOpDisposable
        }
    }
    
    var rx_latestRecordUpdated: Observable<Void> {
        return self.repository.rx_updated
    }
    
}

typealias IInsightsPresenter = (IInsightsInteractor, IInsightsView, DisposeBag) -> Void
let InsightsPresenter: IInsightsPresenter = { interactor, view, disposeBag in
    let mapInsights: (FitnessInfoInsight) -> Observable<[FitnessInfoInsightViewModel]> = { insights in
            let insightsViewModel: [FitnessInfoInsightViewModel] = zip([insights.dayInsight, insights.weekInsight, insights.monthInsight, insights.yearInsight], ["Day", "Week", "Month", "Year"]).map {
                guard let insight = $0.0 else { return nil }
                
                return FitnessInfoInsightViewModel(title: $0.1,
                                                   weight: insight.weight,
                                                   bodyFatWeight: insight.bodyFatWeight,
                                                   muscleWeight: insight.muscleWeight,
                                                   waterPercentage: insight.waterPercentage)
                }.flatMap { $0 }
            
            return Observable.just(insightsViewModel)
    }
        
    interactor.rx_getInsights()
        .flatMap(mapInsights)
        .bindTo(view.rx_insights)
        .addDisposableTo(disposeBag)
    
    interactor.rx_latestRecordUpdated
        .flatMap { return interactor.rx_getInsights() }
        .flatMap(mapInsights)
        .bindTo(view.rx_insights)
        .addDisposableTo(disposeBag)
}
