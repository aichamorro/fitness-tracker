//
//  MetricGraphInteractorTests.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro on 06/02/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Quick
import Nimble
import RxSwift
@testable import FitnessTracker

class MetricGraphInteractorTests: QuickSpec {
    override func spec() {
        describe("") {
            it("Retrieves the results of the current week") {
                let managedObject = SetUpInMemoryManagedObjectContext()
                let repository = CoreDataInfoRepository(managedObjectContext: managedObject)

                var components = DateComponents(calendar: Calendar.current, timeZone: TimeZone(identifier: "Europe/London"),
                                                year: 2017, month: 2, day: 6, hour: 9, minute: 6)
                
                do {
                    let date = components.date!
                    let fitnessInfo = FitnessInfo(weight: 67.01, height: 171, bodyFatPercentage: 19.10, musclePercentage: 34.10, waterPercentage: 55, date: date as NSDate)

                    try repository.save(fitnessInfo)
                } catch {
                    fail()
                
                    return
                }
                
                components.minute = 0
                components.hour = 0
                
                let disposeBag = DisposeBag()
                let date = components.date!
                let interactor = MetricGraphInteractor(repository: repository)

                waitUntil { done in
                    interactor.find(from: Calendar.current.dateBySettingStartOfDay(to: date))
                        .subscribe(onNext: { records in
                            expect(records.count).to(equal(1))
                            done()
                        }, onError: { _ in
                            fail()
                            done()
                        }).addDisposableTo(disposeBag)
                }
            }
        }
    }
}
