//
//  InsightsTests.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 01/01/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation
import Quick
import Nimble
import RxSwift
import RxTest
@testable import FitnessTracker

class InsightsTests: QuickSpec {
    override func spec() {
        describe("As user I would like to see some insights of my data") {
            context("Compare with previous results") {
                it("Creates a comparison of the data from the previous day") {
                    let managedObjectContext = SetUpInMemoryManagedObjectContext()
                    let fitnessInfoRepository = CoreDataInfoRepository(managedObjectContext: managedObjectContext)
                    let interactor = InsightsInteractor(repository: fitnessInfoRepository)
                    let disposeBag = DisposeBag()
                
                    fitnessInfoRepository.rx_save(many:
                        [FitnessInfo(weight: 60.9, height: 171, bodyFatPercentage: 20.0, musclePercentage: 20.0, waterPercentage: 20.0),
                         FitnessInfo(weight: 61.0, height: 171, bodyFatPercentage: 20.0, musclePercentage: 20.0, waterPercentage: 20.0)])
                        .bindNext { _ in }
                        .addDisposableTo(disposeBag)
                    
                    waitUntil { done in
                        interactor.rx_getInsights().subscribe(onNext: { insights in
                            guard let daily = insights.dayInsight else {
                                fail(); done(); return
                            }
                            
                            expect(daily.height).to(equal(0))
                            expect(daily.weight).to(equal(61.0 - 60.9))
                            expect(daily.bodyFatPercentage).to(equal(0.0))
                            expect(daily.musclePercentage).to(equal(0.0))
                            expect(daily.waterPercentage).to(equal(0.0))
                            
                            done()
                        }).addDisposableTo(disposeBag)
                    }
                }
                
                it("Creates a comparison of the data from the previous week") {
                    let managedObjectContext = SetUpInMemoryManagedObjectContext()
                    let coreDataEngine = CoreDataEngine(managedObjectContext: managedObjectContext)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd/MM/yy hh:mm"
                    
                    let dates = ["22/01/17 11:16", "21/01/17 09:18", "20/01/17 07:53", "19/01/17 07:52", "18/01/17 09:17", "17/01/17 09:42", "16/01/17 12:06"].map {
                        return dateFormatter.date(from: $0)!
                    }.reversed()
                    
                    let weekFitnessInfo = [FitnessInfo(weight: 68.28, height: 171, bodyFatPercentage: 20.1, musclePercentage: 33.2, waterPercentage: 54.3),
                                           FitnessInfo(weight: 67.98, height: 171, bodyFatPercentage: 19.9, musclePercentage: 33.5, waterPercentage: 54.4),
                                           FitnessInfo(weight: 67.98, height: 171, bodyFatPercentage: 20.1, musclePercentage: 33.3, waterPercentage: 54.3),
                                           FitnessInfo(weight: 67.82, height: 171, bodyFatPercentage: 20.0, musclePercentage: 33.4, waterPercentage: 54.4),
                                           FitnessInfo(weight: 67.98, height: 171, bodyFatPercentage: 19.7, musclePercentage: 33.7, waterPercentage: 54.6),
                                           FitnessInfo(weight: 67.58, height: 171, bodyFatPercentage: 19.9, musclePercentage: 33.4, waterPercentage: 54.4),
                                           FitnessInfo(weight: 67.41, height: 171, bodyFatPercentage: 19.6, musclePercentage: 33.7, waterPercentage: 54.6)].reversed()
                    
                    for (info, date) in zip(weekFitnessInfo, dates)
                    {
                        _ = coreDataEngine.create(entityName: CoreDataEntity.fitnessInfo.rawValue) { entity in
                            guard let saved = entity as? CoreDataFitnessInfo else { fatalError() }
                            
                            saved.date = date as NSDate
                            saved.weight = info.weight
                            saved.height_ = Int16(info.height)
                            saved.bodyFatPercentage = info.bodyFatPercentage
                            saved.musclePercentage = info.musclePercentage
                            saved.waterPercentage = info.waterPercentage
                        }
                    }
                    
                    let fitnessInfoRepository = CoreDataInfoRepository(managedObjectContext: managedObjectContext)
                    let interactor = InsightsInteractor(repository: fitnessInfoRepository)
                    let disposeBag = DisposeBag()

                    waitUntil { done in
                        interactor.rx_getInsights().subscribe(onNext: { insights in
                            guard let weekly = insights.weekInsight else { fail(); done(); return; }
                            
                            expect(weekly.weight - 0.87 < 0.0000001).to(beTrue())
                            expect(weekly.bodyFatPercentage - 0.5 < 0.0000001).to(beTrue())
                            expect(weekly.musclePercentage - (-0.5) < 0.0000001).to(beTrue())
                            expect(weekly.waterPercentage - (-0.3) < 0.0000001).to(beTrue())

                            done()
                        }).addDisposableTo(disposeBag)
                    }
                }
            }
        }
    }
}
