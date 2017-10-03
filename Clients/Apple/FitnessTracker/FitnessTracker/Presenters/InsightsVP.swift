//
//  InsightsVIP.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 01/01/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

typealias FitnessInfoInsightViewModel = (
    title: String,
    weight: Double,
    bodyFatWeight: Double,
    muscleWeight: Double,
    waterPercentage: Double
)
protocol IInsightsView {
    var rx_insights: AnyObserver<[FitnessInfoInsightViewModel]> { get }
}

typealias IInsightsPresenter = (IFindInsights, IRecordStoreUpdate, IInsightsView, DisposeBag) -> Void
let InsightsPresenter: IInsightsPresenter = { interactor, recordStoreUpdate, view, disposeBag in
    let periodLabels = [
        LocalizableStrings.Insights.Periods.day(),
        LocalizableStrings.Insights.Periods.week(),
        LocalizableStrings.Insights.Periods.month(),
        LocalizableStrings.Insights.Periods.year()
    ]

    let mapInsights: (FitnessInfoInsight) -> Observable<[FitnessInfoInsightViewModel]> = { insights in
        let insightsArray = [
            insights.dayInsight,
            insights.weekInsight,
            insights.monthInsight,
            insights.yearInsight
        ]

        let insightsViewModel: [FitnessInfoInsightViewModel] = zip(insightsArray, periodLabels).map {
            guard let insight = $0.0 else { return nil }

            return FitnessInfoInsightViewModel(title: $0.1,
                                               weight: insight.weight,
                                               bodyFatWeight: insight.bodyFatWeight,
                                               muscleWeight: insight.muscleWeight,
                                               waterPercentage: insight.waterPercentage)
            }.flatMap { $0 }

        return Observable.just(insightsViewModel)
    }

    interactor.rx_output
        .flatMap(mapInsights)
        .bind(to: view.rx_insights)
        .disposed(by: disposeBag)

    recordStoreUpdate.rx_didUpdate
        .bind(to: interactor.rx_input)
        .disposed(by: disposeBag)
}
