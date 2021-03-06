//
//  LatestRecordTests.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 14/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import Quick
import Nimble
import RxSwift
import RxTest
import CoreData
@testable import FitnessTracker

private class LatestRecordView: ILatestRecordView {
    var viewModelVariable = Variable<LatestRecordViewModel>(LatestRecordViewModel.empty)
    var viewModel: LatestRecordViewModel {
        get { return viewModelVariable.value }
        set { viewModelVariable.value = newValue }
    }

    var viewDidLoadSubject = PublishSubject<Void>()
    var rx_viewDidLoad: Observable<Void> {
        return viewDidLoadSubject.asObservable()
    }

    var didSelectMetricSubject = PublishSubject<BodyMetric>()
    var rx_didSelectMetric: Observable<BodyMetric> {
        return didSelectMetricSubject.asObservable()
    }

    func viewDidLoad() {
        viewDidLoadSubject.asObserver().onNext()
    }
}

class LatestRecordTests: QuickSpec {
    // swiftlint:disable function_body_length
    override func spec() {
        describe("So that I can see my fitness info at one glance, as user I would like to see the latest measurements") {
            context("Showing measurements") {

                var view: LatestRecordView!
                var disposeBag: DisposeBag!
                var scheduler: TestScheduler!
                var repository: CoreDataFitnessInfoRepository!
                var managedObjectContext: NSManagedObjectContext!
                var interactor: IFindLatestRecord!
                var router: AppRouter!
                var storeUpdates: IRecordStoreUpdate!

                beforeEach {
                    managedObjectContext = SetUpInMemoryManagedObjectContext()
                    let coreDataEngine = CoreDataEngineImpl(managedObjectContext: managedObjectContext)
                    repository = CoreDataFitnessInfoRepository(coreDataEngine: coreDataEngine)
                    view = LatestRecordView()
                    disposeBag = DisposeBag()
                    scheduler = TestScheduler(initialClock: 0)
                    interactor = FindLatestRecord(repository: repository)
                    storeUpdates = RecordStoreUpdate(repository: repository)
                    router = DefaultAppRouter()

                    LatestRecordPresenter(interactor, storeUpdates, view, router, disposeBag)
                }

                afterEach {
                    view = nil
                    managedObjectContext.reset()
                    managedObjectContext = nil
                    repository = nil
                    interactor = nil
                    scheduler.stop()
                    scheduler = nil
                    router = nil
                }

                it("Shows the latest record data") {
                    do {
                        try repository.save(FitnessInfo(weight: 34.5,
                                                        height: 171,
                                                        bodyFatPercentage: 30.0,
                                                        musclePercentage: 30.0,
                                                        waterPercentage: 41.0))
                    } catch {
                        fail()
                        return
                    }

                    createObserverAndSubscribe(to: view.viewModelVariable.asObservable().skip(2),
                                               scheduler: scheduler,
                                               disposeBag: disposeBag,
                                               expect: { viewModel in
                        expect(viewModel.weight - 34.5 < 0.000001).to(beTrue())
                        expect(viewModel.height).to(equal(171))
                        expect(viewModel.bodyFat - 30.0 < 0.000001).to(beTrue())
                        expect(viewModel.muscle - 30.0 < 0.000001).to(beTrue())
                        expect(viewModel.water - 41.0 < 0.000001).to(beTrue())
                    }, action: {
                        view.viewDidLoad()
                    })
                }

                it("Doesn't crash when there is no previous data recorded") {
                    createObserverAndSubscribe(to: view.viewModelVariable.asObservable().skip(2),
                                               scheduler: scheduler,
                                               disposeBag: disposeBag,
                                               expect: { viewModel in
                        expect(viewModel.weight).to(equal(0))
                        expect(viewModel.height).to(equal(0))
                        expect(viewModel.bodyFat).to(equal(0))
                        expect(viewModel.muscle).to(equal(0))
                        expect(viewModel.water).to(equal(0))
                    }, action: {
                        view.viewDidLoad()
                    })
                }
            }
        }
    }
}
