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
@testable import FitnessTracker

class LatestRecordTests: QuickSpec {
    override func spec() {
        describe("So that I can see my fitness info at one glance, as user I would like to see the latest measurements") {
            context("Showing measurements") {
                
                var view: LatestRecordView!
                var disposeBag: DisposeBag!
                var scheduler: TestScheduler!
                var presenter: ILatestRecordPresenter!
                var repository: CoreDataInfoRepository!
                var managedObjectContext: NSManagedObjectContext!
                var interactor: ILatestRecordInteractor!
                
                
                beforeEach {
                    managedObjectContext = SetUpInMemoryManagedObjectContext()
                    repository = CoreDataInfoRepository(managedObjectContext: managedObjectContext)
                    view = LatestRecordView()
                    disposeBag = DisposeBag()
                    scheduler = TestScheduler(initialClock: 0)
                    presenter = LatestRecordPresenter
                    interactor = LatestRecordInteractor(repository: repository)
                    
                    presenter(interactor, view, disposeBag)
                }
                
                afterEach {
                    presenter = nil
                    view = nil
                    managedObjectContext.reset()
                    managedObjectContext = nil
                    repository = nil
                    interactor = nil
                    scheduler.stop()
                    scheduler = nil
                }
                
                it("Shows the latest record data") {
                    repository.save(record: FitnessInfo(weight: 34.5, height: 171, bodyFatPercentage: 30.0, musclePercentage: 30.0))
                    
                    createObserverAndSubscribe(to: view.viewModelVariable.asObservable().skip(1), scheduler: scheduler, disposeBag: disposeBag, expect: { viewModel in
                        expect(viewModel.weight - 34.5 < 0.000001).to(beTrue())
                        expect(viewModel.height).to(equal(171))
                        expect(viewModel.bodyFat - 30.0 < 0.000001).to(beTrue())
                        expect(viewModel.muscle - 30.0 < 0.000001).to(beTrue())
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
                    }, action: {
                        view.viewDidLoad()
                    })
                }                
            }
        }
    }
}
