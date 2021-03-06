//
//  CoreDataFitnessInfoRepositoryTests.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 25/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import Quick
import Nimble
import CoreData
import RxTest
import RxSwift
@testable import FitnessTracker

class CoreDataFitnessInfoRepositoryTests: QuickSpec {
    // swiftlint:disable function_body_length
    override func spec() {
        describe("A repository should be able to fulfill a CRUD contract") {
            var repository: IFitnessInfoRepository!
            var disposeBag: DisposeBag!
            var scheduler: TestScheduler!

            beforeEach {
                let coreDataEngine = CoreDataEngineImpl(managedObjectContext: SetUpInMemoryManagedObjectContext())
                repository = CoreDataFitnessInfoRepository(coreDataEngine: coreDataEngine)
                scheduler = TestScheduler(initialClock: 0)
                disposeBag = DisposeBag()
            }

            afterEach {
                repository = nil
                scheduler = nil
                disposeBag = nil
            }

            context("Fetching records") {

                it("Returns an empty result when fetching if there is no data") {
                    createObserverAndSubscribe(to: repository.rx_findLatest(numberOfRecords: 5),
                                               scheduler: scheduler,
                                               disposeBag: disposeBag,
                                               expect: { result in
                        expect(result).to(beEmpty())
                    }, action: {})
                }

                it("Can return a single result") {
                    let expected = FitnessInfo(weight: 60.0,
                                               height: 171,
                                               bodyFatPercentage: 30.0,
                                               musclePercentage: 30.0,
                                               waterPercentage: 0.0)
                    repository.rx_save(expected)
                        .do(onNext: nil, onError: { _ in fail() })
                        .subscribe(onNext: nil)
                        .addDisposableTo(disposeBag)

                    createObserverAndSubscribe(to: repository.rx_findLatest(numberOfRecords: 5),
                                               scheduler: scheduler,
                                               disposeBag: disposeBag,
                                               expect: { result in
                        expect(result.count).to(equal(1))

                        guard let first = result.first else {
                            fail()

                            return
                        }

                        expect(first == expected).to(beTrue())
                    }, action: { })
                }

                it("Can return several results ordered from latest to oldest") {
                    let firstExpected = FitnessInfo(weight: 60.0,
                                                    height: 171,
                                                    bodyFatPercentage: 30.0,
                                                    musclePercentage: 30.0,
                                                    waterPercentage: 0.0)
                    let secondExpected = FitnessInfo(weight: 65.0,
                                                     height: 171,
                                                     bodyFatPercentage: 40.0,
                                                     musclePercentage: 50.0,
                                                     waterPercentage: 0.0)

                    repository.rx_save(many: [secondExpected, firstExpected])
                        .do(onNext: nil, onError: { _ in fail() })
                        .subscribe(onNext: nil)
                        .addDisposableTo(disposeBag)

                    createObserverAndSubscribe(to: repository.rx_findLatest(numberOfRecords: 5),
                                               scheduler: scheduler,
                                               disposeBag: disposeBag,
                                               expect: { result in
                                                expect(result.count).to(equal(2))

                                                expect(result[0] == firstExpected).to(beTrue())
                                                expect(result[1] == secondExpected).to(beTrue())
                    }, action: { })
                }
            }

            context("Saving records") {
                it("Can save a record with set date") {
                    guard let date = DateComponents(calendar: Calendar.current,
                                                    timeZone: TimeZone(identifier: "Europe/London"),
                                                    year: 2017, month: 2, day: 6, hour: 9, minute: 6).date else {
                        fail()
                        return
                    }

                    let info = FitnessInfo(weight: 60.0,
                                           height: 171,
                                           bodyFatPercentage: 19.2,
                                           musclePercentage: 34.10,
                                           waterPercentage: 55,
                                           date: date as NSDate?)

                    do {
                        let saved = try repository.save(info)
                        expect(saved.date! as Date).to(equal(date))
                    } catch {
                        fail(error.localizedDescription)
                        return
                    }
                }

                it("Notifies when the repository has been updated") {
                    let any = FitnessInfo(weight: 60.0, height: 171, bodyFatPercentage: 30.0, musclePercentage: 30.0, waterPercentage: 0)

                    waitUntil(timeout: 5) { done in
                        repository.rx_updated
                            .subscribe(onNext: {
                            done()
                        }).addDisposableTo(disposeBag)

                        repository.rx_save(any).subscribe(onNext: nil).addDisposableTo(disposeBag)
                    }
                }
            }

            context("Removing records") {
                var saved: IFitnessInfo!
                var removed: IFitnessInfo?

                beforeEach {
                    expect(repository.findAll()).to(beEmpty())

                    let any = FitnessInfo(weight: 60.0,
                                          height: 171,
                                          bodyFatPercentage: 30.0,
                                          musclePercentage: 30.0,
                                          waterPercentage: 0)

                    saved = try! repository.save(any)
                    expect(repository.findAll().count).to(equal(1))

                    waitUntil { done in
                        repository.rx_remove(saved).subscribe(onNext: {
                            removed = $0
                            done()
                        }, onError: { _ in
                            fail()
                            done()
                        }).addDisposableTo(disposeBag)
                    }
                }

                it("Removed the item from the repository") {
                    expect(repository.findAll()).to(beEmpty())
                }

                it("Returns the removed item") {
                    expect(removed != nil && removed! == saved).to(beTrue())
                }

                context("When the records does not exist") {
                    var nonExistingRemoved: IFitnessInfo?

                    beforeEach {
                        expect(repository.findAll()).to(beEmpty())
                        waitUntil { done in
                            repository.rx_remove(saved)
                                .subscribe(onNext: {
                                    nonExistingRemoved = $0
                                    done()
                                }, onError: {_ in
                                    fail()
                                    done()
                                }).addDisposableTo(disposeBag)
                        }
                    }

                    it("Returns nil") {
                        expect(nonExistingRemoved).to(beNil())
                    }
                }
            }
        }
    }
}
