//
//  MetricHistoryTests.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 27/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import Quick
import Nimble
import RxTest
import RxSwift
@testable import FitnessTracker

final class FakeMetricHistoryView: IMetricHistoryView {
    var selectedMetric: BodyMetric = .weight
    fileprivate var metricDataVariable: Variable<[MetricDataReading]> = Variable([])

    var hasUpdated = false
    func update() {
        hasUpdated = true
    }

    fileprivate let rx_loadHistoricDataSubject = PublishSubject<Void>()
    var rx_loadHistoricData: Observable<Void> {
        return rx_loadHistoricDataSubject.asObservable()
    }

    var rx_metricData: AnyObserver<[MetricDataReading]> {
        return AnyObserver { [unowned self] event in
            switch event {
            case .next(let element):
                self.metricDataVariable.value = element
            default:
                break
            }
        }
    }

    var _noHistoricalDataWarningShown = false
    func showNoHistoricalDataWarning() {
        _noHistoricalDataWarningShown = true
    }
}

class MetricHistoryTests: QuickSpec {
    // swiftlint:disable function_body_length
    override func spec() {
        describe("As user I would like to be able to see the history of my readings, per metric") {
            context("Showing historical data for a metric") {

                var view: FakeMetricHistoryView!
                var repository: IFitnessInfoRepository!
                var interactor: IFindAllRecords!
                var disposeBag: DisposeBag!

                beforeEach {
                    view = FakeMetricHistoryView()
                    disposeBag = DisposeBag()
                    let coreDataEngine = CoreDataEngineImpl(managedObjectContext: SetUpInMemoryManagedObjectContext())
                    repository = CoreDataInfoRepository(coreDataEngine: coreDataEngine)
                    interactor = FindAllRecords(repository: repository)
                    MetricHistoryPresenter(interactor, view, disposeBag)
                }

                afterEach {
                    view = nil
                    disposeBag = nil
                    repository = nil
                    interactor = nil
                }
                it("Shows a warning if there is no historical data for a metric") {
                    view.rx_loadHistoricDataSubject.onNext()
                    expect(view._noHistoricalDataWarningShown).to(beTrue())
                }

                context("Can show chronologically sorted data for each metric") {
                    beforeEach {
                        repository.rx_save(many: [
                            FitnessInfo(weight: 60.5, height: 171, bodyFatPercentage: 30.4, musclePercentage: 20.0, waterPercentage: 20.0),
                            FitnessInfo(weight: 60.0, height: 171, bodyFatPercentage: 30.4, musclePercentage: 20.5, waterPercentage: 22.0),
                            FitnessInfo(weight: 63.0, height: 171, bodyFatPercentage: 31.0, musclePercentage: 20.8, waterPercentage: 24.0)
                            ]).subscribe(onNext: nil, onError: { _ in fail() })
                            .addDisposableTo(disposeBag)
                    }

                    it("Shows data for body fat percentages") {
                        view.selectedMetric = .bodyFatPercentage
                        view.rx_loadHistoricDataSubject.onNext()
                        expect(view._noHistoricalDataWarningShown).to(beFalse())
                        expect(view.metricDataVariable.value.map { return $0.reading }).to(equal(["31.0", "30.4", "30.4"]))
                    }

                    it("Shows data for muscle percentage") {
                        view.selectedMetric = .musclePercentage
                        view.rx_loadHistoricDataSubject.onNext()
                        expect(view._noHistoricalDataWarningShown).to(beFalse())
                        expect(view.metricDataVariable.value.map { return $0.reading }).to(equal(["20.8", "20.5", "20.0"]))
                    }

                    it("Shows data for height") {
                        view.selectedMetric = .height
                        view.rx_loadHistoricDataSubject.onNext()
                        expect(view._noHistoricalDataWarningShown).to(beFalse())
                        expect(view.metricDataVariable.value.map { return $0.reading }).to(equal(["171.0", "171.0", "171.0"]))
                    }

                    it("Shows data for weight") {
                        view.selectedMetric = .weight
                        view.rx_loadHistoricDataSubject.onNext()
                        expect(view._noHistoricalDataWarningShown).to(beFalse())
                        expect(view.metricDataVariable.value.map { return $0.reading }).to(equal(["63.0", "60.0", "60.5"]))
                    }

                    it("Shows data for water") {
                        view.selectedMetric = .waterPercentage
                        view.rx_loadHistoricDataSubject.onNext()
                        expect(view._noHistoricalDataWarningShown).to(beFalse())
                        expect(view.metricDataVariable.value.map { return $0.reading }).to(equal(["24.0", "22.0", "20.0"]))
                    }

                }
            }
        }
    }
}
