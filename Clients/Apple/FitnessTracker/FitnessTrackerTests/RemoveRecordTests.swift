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
            it("Can remove a record") {
                let managedObjectContext = SetUpInMemoryManagedObjectContext()
                let coreDataEngine = CoreDataEngineImpl(managedObjectContext: managedObjectContext)
                let repository = CoreDataInfoRepository(coreDataEngine: coreDataEngine)
                let removeRecordInteractor = RemoveReadingInteractor(infoRepository: repository)
                let saveRecordInteractor = CreateNewRecord(repository: repository, healthKitRepository: DummyHealthKitRepository())
                let disposeBag = DisposeBag()

                waitUntil { done in
                    removeRecordInteractor
                        .rx_output
                        .subscribe(onNext: {
                            expect($0).to(beTrue())
                            done()
                        }).addDisposableTo(disposeBag)

                    saveRecordInteractor
                        .rx_output
                        .subscribe(onNext: { record in
                            removeRecordInteractor.rx_input.onNext(record)
                        }).addDisposableTo(disposeBag)
                }
            }
        }
    }
}

class RemoveReadingInteractor: AnyInteractor<IFitnessInfo, Bool> {
    init(infoRepository: IFitnessInfoRepository) {
        super.init { _ -> Observable<Bool> in
            return Observable.just(false)
        }

    }
}
