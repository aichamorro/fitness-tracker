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
                            expect(daily.weight).to(equal(60.9 - 61.0))
                            expect(daily.bodyFatPercentage).to(equal(0.0))
                            expect(daily.musclePercentage).to(equal(0.0))
                            expect(daily.waterPercentage).to(equal(0.0))
                            
                            done()
                        }).addDisposableTo(disposeBag)
                    }
                }
                
                it("Creates a comparison of the data from the previous week") {
                    
                }
            }
        }
    }
}
