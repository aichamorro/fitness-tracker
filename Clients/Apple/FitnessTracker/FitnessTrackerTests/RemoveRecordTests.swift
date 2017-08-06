//
//  RemoveRecordTests.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 30/07/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation
import Quick
import Nimble
import RxSwift
@testable import FitnessTracker

class RemoveReadingInteractorTests: QuickSpec {
    // swiftlint:disable function_body_length
    override func spec() {
        describe("As user I would like to be able to remove readings") {
            var repository: CoreDataFitnessInfoRepository!
            var removeRecordInteractor: RemoveReadingInteractor!
            var disposeBag: DisposeBag!
            let record: IFitnessInfo = FitnessInfo(weight: 72.2, height: 171, bodyFatPercentage: 20.9, musclePercentage: 35.1, waterPercentage: 53.7)

            beforeEach {
                let managedObjectContext = SetUpInMemoryManagedObjectContext()
                let coreDataEngine = CoreDataEngineImpl(managedObjectContext: managedObjectContext)
                repository = CoreDataFitnessInfoRepository(coreDataEngine: coreDataEngine)
                removeRecordInteractor = RemoveReadingInteractorImpl(repository: repository)
                disposeBag = DisposeBag()
            }

            context("When there is a record in the repository") {
                var saved: IFitnessInfo!
                var didRemove = false
                var repositoryDidUpdate = false

                beforeEach {
                    saved = try! repository.save(record)
                    expect(repository.findAll().count).to(equal(1))

                    repository.rx_updated
                        .subscribe(onNext: {
                            repositoryDidUpdate = true
                        }).addDisposableTo(disposeBag)

                    waitUntil { done in
                        removeRecordInteractor
                            .rx_output
                            .subscribe(onNext: {
                                didRemove = ($0 != nil)
                                done()
                            }).addDisposableTo(disposeBag)

                        removeRecordInteractor.rx_input.onNext(saved)
                    }
                }

                it("Was removed") {
                    expect(didRemove).to(beTrue())
                    expect(repository.findAll()).to(beEmpty())
                }

                it("Notifies of changes in the repository") {
                    expect(repositoryDidUpdate).toEventually(beTrue())
                }
            }

            context("When there is no matching record in the repository") {
                var didThrow = true
                var didRemove = true

                beforeEach {
                    let saved = try! repository.save(record)
                    try! repository.remove(saved)

                    waitUntil { done in
                        removeRecordInteractor
                            .rx_output
                            .subscribe(onNext: {
                                didThrow = false
                                didRemove = ($0 != nil && $0! == saved)
                                done()
                            }, onError: { _ in
                                didThrow = true
                                done()
                            }).addDisposableTo(disposeBag)

                        removeRecordInteractor.rx_input.onNext(saved)
                    }
                }

                it("Does not throw") {
                    expect(didRemove).to(beFalse())
                    expect(didThrow).to(beFalse())
                }
            }

        }
    }
}

class DummyRemoveReadingView: RemoveReadingView {
    let removeReadingSubject = PublishSubject<IFitnessInfo>()
    var saved: [IFitnessInfo] = []

    var rx_removeReading: Observable<IFitnessInfo> {
        return removeReadingSubject.asObservable()
    }
}

class RemoveReadingPresenterSpec: QuickSpec {
    override func spec() {
        describe("The Presenter works in conjunction with the interactor") {
            var interactor: RemoveReadingInteractor!
            var disposeBag: DisposeBag!
            var view: RemoveReadingView!

            beforeEach {
                disposeBag = DisposeBag()

                let coreDataEngine = CoreDataEngineImpl(managedObjectContext: SetUpInMemoryManagedObjectContext())
                let repository = CoreDataFitnessInfoRepository(coreDataEngine: coreDataEngine)
                try! repository.save(FitnessInfo(weight: 71.8, height: 171, bodyFatPercentage: 20.9, musclePercentage: 35.0, waterPercentage: 53.7))
                try! repository.save(FitnessInfo(weight: 71.8, height: 171, bodyFatPercentage: 20.9, musclePercentage: 35.0, waterPercentage: 53.7))
                try! repository.save(FitnessInfo(weight: 71.8, height: 171, bodyFatPercentage: 20.9, musclePercentage: 35.0, waterPercentage: 53.7))
                try! repository.save(FitnessInfo(weight: 71.8, height: 171, bodyFatPercentage: 20.9, musclePercentage: 35.0, waterPercentage: 53.7))
                try! repository.save(FitnessInfo(weight: 71.8, height: 171, bodyFatPercentage: 20.9, musclePercentage: 35.0, waterPercentage: 53.7))

                let dummyView = DummyRemoveReadingView()
                dummyView.saved = repository.findAll()

                view = dummyView

                interactor = RemoveReadingInteractorImpl(repository: repository)
                RemoveReadingPresenterImpl(interactor, view, disposeBag)
            }

            afterEach {
                interactor = nil
            }

            context("Removing an item") {
                var removed: IFitnessInfo?

                beforeEach {
                    let dummyView = view as! DummyRemoveReadingView

                    waitUntil { done in
                        interactor.rx_output.subscribe(onNext: {
                            removed = $0
                            done()
                        }, onError: { _ in
                            fail()
                            done()
                        }).addDisposableTo(disposeBag)

                        dummyView.removeReadingSubject.asObserver().onNext(dummyView.saved[0])
                    }

                }

                it("Can remove an item") {
                    expect(removed).toNot(beNil())
                }
            }
        }
    }
}
