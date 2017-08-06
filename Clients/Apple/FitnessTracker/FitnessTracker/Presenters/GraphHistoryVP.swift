//
//  GraphHistoryVIP.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro on 01/02/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

protocol IMetricGraphView {
    var rx_loadLatestRecords: Observable<Date> { get }
    var rx_graphData: AnyObserver<[IFitnessInfo]> { get }
    var selectedMetric: BodyMetric { get }
}

private extension Int {
    var doubleValue: Double {
        return Double(self)
    }
}

typealias IMetricGraphPresenter = (IFindRecordsInInterval, IMetricGraphView, DisposeBag) -> Void
let MetricGraphPresenter: IMetricGraphPresenter = { (interactor, view, disposeBag) in
    interactor.rx_output
        .bindTo(view.rx_graphData)
        .addDisposableTo(disposeBag)

    view.rx_loadLatestRecords
        .map {
            let from = Calendar.current.dateBySettingStartOfDay(to: $0)
            let to = Calendar.current.endOfToday

            return (from, to)
        }.bindTo(interactor.rx_input)
        .addDisposableTo(disposeBag)
}
