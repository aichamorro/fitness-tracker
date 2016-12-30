//
//  ShowMetricHistoricalData.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 27/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

enum BodyMetric: String {
    case height
    case weight
    case bodyFatPercentage
    case musclePercentage
    case waterPercentage
    case bodyFatWeight
    case muscleWeight
    case waterWeight
    case leanBodyWeight
    case bmi
}

extension BodyMetric {
    var description: String {
        switch self {
        case .height: return "Height"
        case .weight: return "Weight"
        case .bodyFatPercentage: return "Body Fat (%)"
        case .musclePercentage: return "Muscle (%)"
        case .waterPercentage: return "Water (%)"
        case .bodyFatWeight: return "Body Fat (Kg)"
        case .muscleWeight: return "Muscle (Kg)"
        case .waterWeight: return "Water (Kg)"
        case .leanBodyWeight: return "Lean Body Weight (Kg)"
        case .bmi: return "BMI"
        }
    }
}

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
        
        return repository.findAll().flatMap { fetched in
            return Observable.just(convertArray(fetched))
        }
    }
}

private extension IFitnessInfo {
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
