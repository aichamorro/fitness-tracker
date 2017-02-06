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
import URLRouter
@testable import FitnessTracker

class LatestRecordTests: QuickSpec {
    override func spec() {
        describe("So that I can see my fitness info at one glance, as user I would like to see the latest measurements") {
            context("Showing measurements") {
                
                var view: LatestRecordView!
                var disposeBag: DisposeBag!
                var scheduler: TestScheduler!
                var repository: CoreDataInfoRepository!
                var managedObjectContext: NSManagedObjectContext!
                var interactor: ILatestRecordInteractor!
                var router: AppRouter!
                    
                beforeEach {
                    managedObjectContext = SetUpInMemoryManagedObjectContext()
                    repository = CoreDataInfoRepository(managedObjectContext: managedObjectContext)
                    view = LatestRecordView()
                    disposeBag = DisposeBag()
                    scheduler = TestScheduler(initialClock: 0)
                    interactor = LatestRecordInteractor(repository: repository)
                    router = AppRouter.empty
                    LatestRecordPresenter(interactor, view, router, disposeBag)
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
                        try repository.save(record: FitnessInfo(weight: 34.5, height: 171, bodyFatPercentage: 30.0, musclePercentage: 30.0, waterPercentage: 41.0))
                    } catch {
                        fail()
                        return
                    }
                    
                    createObserverAndSubscribe(to: view.viewModelVariable.asObservable().skip(1), scheduler: scheduler, disposeBag: disposeBag, expect: { viewModel in
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
                    createObserverAndSubscribe(to: view.viewModelVariable.asObservable().skip(1), scheduler: scheduler, disposeBag: disposeBag, expect: { viewModel in
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
