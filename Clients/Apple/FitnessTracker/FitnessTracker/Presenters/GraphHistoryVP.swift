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

    func reload()
}

private extension Int {
    var doubleValue: Double {
        return Double(self)
    }
}

typealias IMetricGraphPresenter = (IFindRecordsInInterval, IRecordStoreUpdate, IMetricGraphView, DisposeBag) -> Void
let MetricGraphPresenter: IMetricGraphPresenter = { (interactor, onRecordStoreUpdate, view, disposeBag) in
    interactor.rx_output
        .bind(to: view.rx_graphData)
        .disposed(by: disposeBag)

    view.rx_loadLatestRecords
        .map {
            let from = Calendar.current.dateBySettingStartOfDay(to: $0)
            let to = Calendar.current.endOfToday

            return (from, to)
        }.bind(to: interactor.rx_input)
        .disposed(by: disposeBag)

    onRecordStoreUpdate
        .rx_didUpdate
        .subscribe(onNext: {
            view.reload()
        }).disposed(by: disposeBag)
}
