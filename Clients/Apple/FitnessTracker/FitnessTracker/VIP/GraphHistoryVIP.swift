//
//  GraphHistoryVIP.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro on 01/02/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

protocol IMetricGraphInteractor {
    func findRecordsForCurrentWeek(for bodyMetric: BodyMetric) -> Observable<[(NSDate, Double)]>
}

protocol IMetricGraphView {
    var rx_loadCurrentWeek: Observable<Void> { get }
    var rx_graphData: AnyObserver<([Double], [Double])> { get }
    var selectedMetric: BodyMetric { get }
}

typealias IMetricGraphPresenter = (IMetricGraphInteractor, IMetricGraphView, DisposeBag) -> Void
let MetricGraphPresenter: IMetricGraphPresenter = { (interactor, view, disposeBag) in
    view.rx_loadCurrentWeek
        .flatMap { interactor.findRecordsForCurrentWeek(for: view.selectedMetric) }
        .bindNext { info in
            let calendar = Calendar.current
            var dates: [Double] = []
            var readings: [Double] = []
            
            _ = info.map { return ($0.0, $0.1) }.reduce([]) { result, current in
                let day = calendar.component(.day, from:current.0 as Date)
                dates.append(Double(day))
                readings.append(Double(current.1))
                
                return result
            }
            
            view.rx_graphData.onNext((dates, readings))
        }.addDisposableTo(disposeBag)
}

final class MetricGraphInteractor: IMetricGraphInteractor {
    private let fitnessInfoRepository: IFitnessInfoRepository
    
    init(repository: IFitnessInfoRepository) {
        self.fitnessInfoRepository = repository
    }
    
    func findRecordsForCurrentWeek(for bodyMetric: BodyMetric) -> Observable<[(NSDate, Double)]> {
        return fitnessInfoRepository
            .rx_findLatest(numberOfRecords: 7)
            .flatMap { fetched in
                return Observable.just(fetched.map {
                    return ($0.date!, $0.value(for: bodyMetric).doubleValue)
                })
            }
    }
}
