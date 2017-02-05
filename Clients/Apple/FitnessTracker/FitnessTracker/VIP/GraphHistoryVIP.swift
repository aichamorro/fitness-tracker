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
    func find(from: Date) -> Observable<[IFitnessInfo]>
}

protocol IMetricGraphView {
    var rx_loadLatestRecords: Observable<Date> { get }
    var rx_graphData: AnyObserver<([Double], [Double])> { get }
    var selectedMetric: BodyMetric { get }
}

private extension Int {
    var doubleValue: Double {
        return Double(self)
    }
}

private let calendar = Calendar.current
private func FitnessInfoToGraphDataAdapter(bodyMetric: BodyMetric) -> ([IFitnessInfo]) -> ([Double], [Double]) {
    return { data in
        var dates: [Double] = []
        var readings: [Double] = []
        
        data.forEach { info in
            let alignedDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: info.date! as Date)!
            dates.append(alignedDate.timeIntervalSinceReferenceDate)
            readings.append(info.value(for: bodyMetric).doubleValue)
        }
        
        return (dates, readings)
    }
}

typealias IMetricGraphPresenter = (IMetricGraphInteractor, IMetricGraphView, DisposeBag) -> Void
let MetricGraphPresenter: IMetricGraphPresenter = { (interactor, view, disposeBag) in
    view.rx_loadLatestRecords
        .flatMap { interactor.find(from: $0) }
        .map(FitnessInfoToGraphDataAdapter(bodyMetric: view.selectedMetric))
        .bindTo(view.rx_graphData)
        .addDisposableTo(disposeBag)
}

final class MetricGraphInteractor: IMetricGraphInteractor {
    private let fitnessInfoRepository: IFitnessInfoRepository
    
    init(repository: IFitnessInfoRepository) {
        self.fitnessInfoRepository = repository
    }
    
    func find(from intervalStart: Date) -> Observable<[IFitnessInfo]> {
        return fitnessInfoRepository
            .rx_find(from: intervalStart as NSDate, to: Calendar.current.endOfToday as NSDate, order: .ascendent)
    }
}

