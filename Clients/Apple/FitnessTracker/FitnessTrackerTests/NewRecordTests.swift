//
//  NewRecordTests.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 25/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import Quick
import Nimble
import RxTest
import RxSwift
@testable import FitnessTracker

private class FakeNewRecordView: INewRecordView {
    var height: UInt = 0
    var weight: Double = 0
    var bodyFatPercentage: Double = 0
    var musclePercentage: Double = 0
    var waterPercentage: Double = 0
    var isDismissed = false
    var calibrationFix: Double = 1.0

    private let rx_viewDidLoadSubject = PublishSubject<Void>()
    var rx_viewDidLoad: Observable<Void> { return rx_viewDidLoadSubject.asObservable() }

    private let rx_actionSaveSubject = PublishSubject<NewRecordViewModel>()
    var rx_actionSave: Observable<NewRecordViewModel> { return rx_actionSaveSubject.asObservable() }

    func viewDidLoad() {
        rx_viewDidLoadSubject.onNext()
    }

    func save() {
        rx_actionSaveSubject.onNext(
            NewRecordViewModel(height: height,
                               weight: weight,
                               muscle: musclePercentage,
                               bodyFat: bodyFatPercentage,
                               water: waterPercentage))
    }

    func dismiss() {
        isDismissed = true
    }
}

class NewRecordTests: QuickSpec {

    // swiftlint:disable function_body_length
    override func spec() {
        describe("As user I would like to be able to add new fitness readings") {
            context("It shows the previous reading") {
                var newRecordInteractor: ICreateNewRecord!
                var latestRecordInteractor: IFindLatestRecord!
                var recordStoreUpdates: IRecordStoreUpdate!
                var repository: IFitnessInfoRepository!
                var view: FakeNewRecordView!
                var disposeBag: DisposeBag!
                var scheduler: TestScheduler!

                beforeEach {
                    scheduler = TestScheduler(initialClock: 0)
                    disposeBag = DisposeBag()

                    let managedObjectContext = SetUpInMemoryManagedObjectContext()
                    let coreDataEngine = CoreDataEngineImpl(managedObjectContext: managedObjectContext)
                    repository = CoreDataInfoRepository(coreDataEngine: coreDataEngine)
                    newRecordInteractor = CreateNewRecord(repository: repository, healthKitRepository: DummyHealthKitRepository())
                    recordStoreUpdates = RecordStoreUpdate(repository: repository)
                    latestRecordInteractor = FindLatestRecord(repository: repository)
                    view = FakeNewRecordView()

                    NewRecordPresenter(latestRecordInteractor, newRecordInteractor, view, disposeBag)
                }

                afterEach {
                    newRecordInteractor = nil
                    latestRecordInteractor = nil
                    view = nil
                    disposeBag = nil
                    scheduler.stop()
                    scheduler = nil
                }

                it("Shows the previous reading when there is some previous data") {
                    do {
                        try repository.save(
                            FitnessInfo(weight: 65.0,
                                        height: 171,
                                        bodyFatPercentage: 30.0,
                                        musclePercentage: 40.0,
                                        waterPercentage: 40.0))
                    } catch {
                        fail()
                        return
                    }

                    view.viewDidLoad()

                    expect(view.height).to(equal(171))
                    expect(view.weight).to(equal(65.0))
                    expect(view.bodyFatPercentage).to(equal(30.0))
                    expect(view.musclePercentage).to(equal(40.0))
                    expect(view.waterPercentage).to(equal(40.0))
                }

                it("Shows nothing when there are no previous readings") {
                    view.viewDidLoad()

                    expect(view.height).to(equal(0))
                    expect(view.weight).to(equal(0))
                    expect(view.bodyFatPercentage).to(equal(0))
                    expect(view.musclePercentage).to(equal(0))
                    expect(view.waterPercentage).to(equal(0))
                }

                it("Can save new readings") {
                    view.weight = 60.0
                    view.height = 171
                    view.bodyFatPercentage = 30.0
                    view.musclePercentage = 40.0
                    view.waterPercentage = 34.0

                    createObserverAndSubscribe(
                        to: recordStoreUpdates.rx_didUpdate,
                        scheduler: scheduler,
                        disposeBag: disposeBag,
                        expect: nil, action: {
                            view.save()
                        })

                    latestRecordInteractor
                        .rx_output
                        .subscribe(onNext: { info in
                            expect(info.height).to(equal(171))
                            expect(info.weight).to(equal(60.0))
                            expect(info.bodyFatPercentage).to(equal(30.0))
                            expect(info.musclePercentage).to(equal(40.0))
                            expect(info.waterPercentage).to(equal(34.0))
                        }).addDisposableTo(disposeBag)

                    latestRecordInteractor.rx_input.onNext()
                }

                it("Updates the view when saving a new record") {
                    view.weight = 60.0
                    view.height = 171
                    view.bodyFatPercentage = 30.0
                    view.musclePercentage = 40.0
                    view.waterPercentage = 34.0

                    createObserverAndSubscribe(
                        to: recordStoreUpdates.rx_didUpdate,
                        scheduler: scheduler,
                        disposeBag: disposeBag,
                        expect: nil,
                        action: {
                            view.save()
                        })

                    waitUntil { done in
                        latestRecordInteractor
                            .rx_output
                            .subscribe(onNext: { _ in
                                expect(view.height).to(equal(171))
                                expect(view.weight).to(equal(60.0))
                                expect(view.bodyFatPercentage).to(equal(30.0))
                                expect(view.musclePercentage).to(equal(40.0))
                                expect(view.waterPercentage).to(equal(34.0))
                                done()
                            }).addDisposableTo(disposeBag)

                        latestRecordInteractor.rx_input.onNext()
                    }
                }

                it("Dismisses the view on saving") {
                    view.save()

                    expect(view.isDismissed).to(beTrue())
                }
            }
            context("HealthKit") {
                var interactor: ICreateNewRecord!
                var repository: IFitnessInfoRepository!
                var healthKitRepository: IHealthKitRepository!
                var disposeBag: DisposeBag!

                beforeEach {
                    let coreDataEngine = CoreDataEngineImpl(managedObjectContext: SetUpInMemoryManagedObjectContext())
                    repository = CoreDataInfoRepository(coreDataEngine: coreDataEngine)
                    healthKitRepository = FakeHealthKitRepository()
                    interactor = CreateNewRecord(repository: repository, healthKitRepository: healthKitRepository)
                    disposeBag = DisposeBag()
                }

                it("Writes data in the healthkit repository") {
                    let record = FitnessInfo(weight: 60, height: 171, bodyFatPercentage: 18.8, musclePercentage: 35, waterPercentage: 55, date: Date() as NSDate)

                    waitUntil { done in
                        interactor.rx_output.subscribe(onNext: { _ in
                            guard let fakeHealthKitRepository = healthKitRepository as? FakeHealthKitRepository else {
                                fail()
                                done()

                                return
                            }

                            switch fakeHealthKitRepository.currentState {
                            case .nothing:
                                fail()
                                done()
                                return

                            case .savedValue(let height, let weight, let fat, let leanBodyMass, let bmi, let date):
                                expect(height).to(equal(record.height))
                                expect(weight).to(equal(record.weight))
                                expect(fat).to(equal(record.bodyFatPercentage))
                                expect(leanBodyMass).to(equal(record.leanBodyWeight))
                                expect(bmi).to(equal(record.bmi))
                                expect(date).to(equal(record.date! as Date))
                                done()
                            }
                        }, onError: { _ in
                            fail()
                            done()
                        }).addDisposableTo(disposeBag)

                        interactor.rx_input.onNext(record)
                    }
                }
            }
        }
    }
}

class FakeHealthKitRepository: IHealthKitRepository {
    enum State {
        case nothing
        case savedValue(height: UInt, weight: Double, fat: Double, leanBodyMass: Double, bmi: Double, date: Date)
    }

    var currentState: State = .nothing

    func save(height: UInt, weight: Double, bodyFatPercentage: Double, leanBodyMass: Double, bmi: Double, date: Date) {
        currentState = .savedValue(height: height,
                                   weight: weight,
                                   fat: bodyFatPercentage,
                                   leanBodyMass: leanBodyMass,
                                   bmi: bmi,
                                   date: date)
    }
}
