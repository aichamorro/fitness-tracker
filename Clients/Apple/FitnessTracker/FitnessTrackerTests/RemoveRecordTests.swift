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

class RemoveReadingTests: QuickSpec {
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
                removeRecordInteractor = RemoveReadingInteractor(infoRepository: repository)
                disposeBag = DisposeBag()
            }

            context("When there is a record in the repository") {
                var saved: IFitnessInfo!
                var didRemove: Bool = false

                beforeEach {
                    saved = try! repository.save(record)
                    expect(repository.findAll().count).to(equal(1))

                    waitUntil { done in
                        removeRecordInteractor
                            .rx_output
                            .subscribe(onNext: {
                                didRemove = $0
                                done()
                            }).addDisposableTo(disposeBag)

                        removeRecordInteractor.rx_input.onNext(saved)
                    }
                }

                it("Was removed") {
                    expect(didRemove).to(beTrue())
                    expect(repository.findAll()).to(beEmpty())
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
                                didRemove = $0
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

class RemoveReadingInteractor: AnyInteractor<IFitnessInfo, Bool> {
    init(infoRepository: IFitnessInfoRepository) {
        super.init { record -> Observable<Bool> in
            return infoRepository.rx_remove(record)
        }

    }
}
