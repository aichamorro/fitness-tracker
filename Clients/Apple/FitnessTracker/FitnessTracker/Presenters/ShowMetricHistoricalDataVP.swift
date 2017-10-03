//
//  ShowMetricHistoricalData.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 27/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

// MARK: View
protocol IMetricHistoryView: class {
    var rx_loadHistoricData: Observable<Void> { get }
    var selectedMetric: BodyMetric { get }
    var rx_metricData: AnyObserver<[IFitnessInfo]> { get }

    func showNoHistoricalDataWarning()
    func update()
}

extension IFitnessInfo {
    func value(for metric: BodyMetric) -> NSNumber {
        switch metric {
        case .bmi:
            return NSNumber(value: self.bmi)
        case .bodyFatPercentage:
            return NSNumber(value: self.bodyFatPercentage)
        case .bodyFatWeight:
            return NSNumber(value: self.bodyFatWeight)
        case .height:
            return NSNumber(value: self.height)
        case .weight:
            return NSNumber(value: self.weight)
        case .musclePercentage:
            return NSNumber(value: self.musclePercentage)
        case .muscleWeight:
            return NSNumber(value: self.muscleWeight)
        case .waterPercentage:
            return NSNumber(value: self.waterPercentage)
        case .waterWeight:
            return NSNumber(value: self.waterWeight)
        case .leanBodyWeight:
            return NSNumber(value: self.leanBodyWeight)
        }
    }
}

// MARK: Presenter

typealias IMetricHistoryPresenter = (IFindAllRecords, IRecordStoreUpdate, IMetricHistoryView, DisposeBag) -> Void
let MetricHistoryPresenter: IMetricHistoryPresenter = { interactor, onStoreUpdated, view, disposeBag in
    view.rx_loadHistoricData
        .bind(to: interactor.rx_input)
        .disposed(by: disposeBag)

    interactor
        .rx_output
        .do(onNext: { records in
            if records.isEmpty {
                view.showNoHistoricalDataWarning()
            }
        }).bind {
            view.rx_metricData.onNext($0)
            view.update()
        }
        .disposed(by: disposeBag)

    onStoreUpdated
        .rx_didUpdate
        .bind(to: interactor.rx_input)
        .disposed(by: disposeBag)
}
