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

private extension NSDate {
    class var today: NSDate {
        return NSDate()
    }
}

private let calendar = Calendar.current
private func FitnessInfoToGraphDataAdapter(bodyMetric: BodyMetric) -> ([IFitnessInfo]) -> ([Double], [Double]) {
    return { data in
        var dates: [Double] = []
        var readings: [Double] = []
        
        data.forEach { info in
            dates.append(info.date!.timeIntervalSinceReferenceDate)
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
    
    func find(from: Date) -> Observable<[IFitnessInfo]> {
        return fitnessInfoRepository
            .rx_find(from: from as NSDate, to: Date.today as NSDate, order: .ascendent)
    }
}

