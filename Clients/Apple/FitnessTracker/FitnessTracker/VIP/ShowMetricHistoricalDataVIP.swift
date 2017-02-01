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
    var metricData: [MetricDataReading] { get set }
    
    func showNoHistoricalDataWarning()
    func update()
}

// MARK: Interactor

typealias MetricDataReading = (date: NSDate?, reading: String)

protocol IMetricHistoryInteractor {
    func rx_findAll(for bodyMetric: BodyMetric) -> Observable<[MetricDataReading]>
}

final class MetricHistoryInteractor: IMetricHistoryInteractor {
    let repository: IFitnessInfoRepository
    
    init(repository: IFitnessInfoRepository) {
        self.repository = repository
    }
    
    func rx_findAll(for bodyMetric: BodyMetric) -> Observable<[MetricDataReading]> {
        let convertArray: ([IFitnessInfo]) -> [MetricDataReading] = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 1
            
            return $0.map {
                return ($0.date, formatter.string(from: $0.value(for: bodyMetric))!)
            }
        }
        
        return repository.rx_findAll().flatMap { fetched in
            return Observable.just(convertArray(fetched))
        }
    }
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

typealias IMetricHistoryPresenter = (IMetricHistoryInteractor, IMetricHistoryView, DisposeBag) -> Void
let MetricHistoryPresenter: IMetricHistoryPresenter = { interactor, view, disposeBag in
    view.rx_loadHistoricData
        .flatMap {
            interactor.rx_findAll(for: view.selectedMetric)
        }.bindNext { data in
            guard !data.isEmpty else {
                view.showNoHistoricalDataWarning()
                return
            }
            
            view.metricData = data
            view.update()
        }.addDisposableTo(disposeBag)
}
