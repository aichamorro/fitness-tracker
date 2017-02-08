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
import CoreData
@testable import FitnessTracker

class MetricGraphInteractorTests: QuickSpec {
    override func spec() {
        describe("") {
            var interactor: IMetricGraphInteractor!
            var repository: IFitnessInfoRepository!
            let disposeBag = DisposeBag()

            beforeEach {
                let managedObjectContext = SetUpInMemoryManagedObjectContext()
                
                repository = CoreDataInfoRepository(managedObjectContext: managedObjectContext)
                interactor = MetricGraphInteractor(repository: repository)
            }
            
            context("Given no stored records") {
                it("Returns an empty array") {
                    interactor.find(from: Date()).subscribe(onNext: { records in
                        expect(records).toNot(beNil())
                        expect(records.count).to(equal(0))
                    }, onError: { _ in
                        fail()
                        return
                    }).addDisposableTo(disposeBag)
                }
            }
            
            context("Given stored records") {
                let components = DateComponents(calendar: Calendar.current, timeZone: TimeZone(identifier: "Europe/London"),
                                                year: 2017, month: 2, day: 6, hour: 9, minute: 6)
                
                let record = FitnessInfo(weight: 67.01,
                                         height: 171,
                                         bodyFatPercentage: 19.10,
                                         musclePercentage: 34.10,
                                         waterPercentage: 55,
                                         date: components.date! as NSDate?)
                
                beforeEach {
                    do { try repository.save(record) }
                    catch { fail() }
                    
                }
                
                afterEach {
                    interactor = nil
                }
                
                it("Retrieves the results of the current week") {
                    let startDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: components.date!)!
                    
                    waitUntil { done in
                        interactor.find(from: Calendar.current.dateBySettingStartOfDay(to: startDate))
                            .subscribe(onNext: { records in
                                expect(records.count).to(equal(1))
                                done()
                            }, onError: { _ in
                                fail()
                                done()
                            }).addDisposableTo(disposeBag)
                    }
                }
                
                context("Returns a value if it matches with a date within the boundaries of the interval") {

                    it("Returns a value in the lower boundary") {
                        let startDate = components.date!
                        var endDateComponents = components
                        endDateComponents.day = endDateComponents.day! + 1
                        let endDate =  components.date!

                        waitUntil { done in
                            interactor.find(from: startDate, to: endDate)
                                .subscribe(onNext: { records in
                                    expect(records.count).to(equal(1))
                                    done()
                                }, onError: { _ in
                                    fail()
                                    done()
                                }).addDisposableTo(disposeBag)
                        }
                    }
                    
                    it("Returns a value in the upper boundary") {
                        let endDate = components.date!
                        var startDateComponents = components
                        startDateComponents.day = startDateComponents.day! - 1
                        
                        waitUntil { done in
                            interactor.find(from: startDateComponents.date!, to: endDate)
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
                
                context("Given two recordss") {
                    var anotherRecord: IFitnessInfo!
                    
                    beforeEach {
                        var anotherRecordDateComponents = components
                        anotherRecordDateComponents.day = anotherRecordDateComponents.day! + 1
                        anotherRecord = FitnessInfo(weight: 66.77,
                                                        height: 171,
                                                        bodyFatPercentage: 19.20,
                                                        musclePercentage: 34.10,
                                                        waterPercentage: 54.9,
                                                        date: anotherRecordDateComponents.date! as NSDate?)
                        
                        do { try repository.save(anotherRecord) }
                        catch { fatalError() }
                    }
                    
                    it("returns both records that match the date interval") {
                        waitUntil { done in
                            interactor.find(from: record.date! as Date, to: anotherRecord.date! as Date)
                                .subscribe(onNext: { records in
                                    expect(records.count).to(equal(2))
                                    expect(records[0] == record).to(beTrue())
                                    expect(records[1] == anotherRecord).to(beTrue())
                                    done()
                                }, onError: { _ in
                                    fail()
                                    done()
                                }).addDisposableTo(disposeBag)
                        }
                    }
                    
                    it("Leaves out records that don't match the interval criteria") {
                        waitUntil { done in
                            interactor.find(from: record.date! as Date, to: record.date! as Date)
                                .subscribe(onNext: { records in
                                    expect(records.count).to(equal(1))
                                    expect(records.first! == record).to(beTrue())
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
    }
}
