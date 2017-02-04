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
    func find(from: Date, for bodyMetric: BodyMetric) -> Observable<[(NSDate, Double)]>
}

protocol ICurrentWeekGraphInteractor {
    func findCurrentWeek() -> Observable<[IFitnessInfo]>
}

protocol IMetricGraphView {
    var rx_loadLatestRecords: Observable<Date> { get }
    var rx_graphData: AnyObserver<([Double], [Double])> { get }
    var selectedMetric: BodyMetric { get }
}

protocol ICurrentWeekGraphView {
    var rx_loadCurrentWeekRecords: Observable<Void> { get }
    var rx_graphData: AnyObserver<([Double], [Double])> { get }
    var selectedMetric: BodyMetric { get }
}

private extension Int {
    var doubleValue: Double {
        return Double(self)
    }
}

private extension NSDate {
    class var today: NSDate {
        return NSDate()
    }
}

private let calendar = Calendar.current
private func FitnessInfoToGraphDataAdapter(bodyMetric: BodyMetric) -> ([IFitnessInfo]) -> ([Double],[Double]) {
    return { data in
        var dates: [Double] = []
        var readings: [Double] = []
        
        data.forEach { info in
            let day = calendar.component(.day, from: info.date! as Date)
            dates.append(day.doubleValue)
            readings.append(info.value(for: bodyMetric).doubleValue)
        }
        
        return (dates, readings)
    }
}

typealias ICurrentWeekGraphPresenter = (ICurrentWeekGraphInteractor, ICurrentWeekGraphView, DisposeBag) -> Void
let CurrentWeekGraphPresenter: ICurrentWeekGraphPresenter = { interactor, view, disposeBag in
    view.rx_loadCurrentWeekRecords
        .flatMap {
            interactor.findCurrentWeek()
        }.map(FitnessInfoToGraphDataAdapter(bodyMetric: view.selectedMetric))
        .bindTo(view.rx_graphData)
        .addDisposableTo(disposeBag)
}

typealias IMetricGraphPresenter = (IMetricGraphInteractor, IMetricGraphView, DisposeBag) -> Void
let MetricGraphPresenter: IMetricGraphPresenter = { (interactor, view, disposeBag) in
    view.rx_loadLatestRecords
        .flatMap { interactor.find(from: $0, for: view.selectedMetric) }
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
    
    func find(from: Date, for bodyMetric: BodyMetric) -> Observable<[(NSDate, Double)]> {
        return fitnessInfoRepository
            .rx_find(from: from as NSDate, to: Date.now as NSDate, order: .ascendent)
            .flatMap { fetched in
                return Observable.just(fetched.map {
                    return ($0.date!, $0.value(for: bodyMetric).doubleValue)
                })
            }
    }
}

final class CurrentWeekGraphInteractor: ICurrentWeekGraphInteractor {
    private let fitnessInfoRepository: IFitnessInfoRepository
    
    init(repository: IFitnessInfoRepository) {
        self.fitnessInfoRepository = repository
    }
    
    func findCurrentWeek() -> Observable<[IFitnessInfo]> {
        return fitnessInfoRepository.rx_findWeek(ofDay: NSDate.today)
    }
}
