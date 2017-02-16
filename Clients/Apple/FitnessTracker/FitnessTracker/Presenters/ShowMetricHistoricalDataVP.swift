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
    var rx_metricData: AnyObserver<[MetricDataReading]> { get }
    
    func showNoHistoricalDataWarning()
    func update()
}

typealias MetricDataReading = (date: NSDate?, reading: String)
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

func convert(fitnessRecords: [IFitnessInfo], toBodyMetricReading bodyMetric: BodyMetric) -> [MetricDataReading] {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 1
    
    return fitnessRecords.map {
        return ($0.date, formatter.string(from: $0.value(for: bodyMetric))!)
    }
}

typealias IMetricHistoryPresenter = (IFindAllRecords, IMetricHistoryView, DisposeBag) -> Void
let MetricHistoryPresenter: IMetricHistoryPresenter = { interactor, view, disposeBag in
    view.rx_loadHistoricData
        .bindTo(interactor.rx_input)
        .addDisposableTo(disposeBag)
    
    interactor.rx_output.map {
            return convert(fitnessRecords: $0, toBodyMetricReading: view.selectedMetric)
        }.do(onNext: { records in
            if records.isEmpty {
                view.showNoHistoricalDataWarning()
            }
            
            view.update()
        }).bindTo(view.rx_metricData)
        .addDisposableTo(disposeBag)
}
