//
//  LogRepositoryTests.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 14/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import FitnessTracker

class LogRepositoryTests: QuickSpec {
    override func spec() {
        describe("So that I can keep track of my fitness data, as user I would like to be able to store a daily log with my fitness data") {
            var repository: IFitnessLogRepository!
            var info: FitnessInfo!

            beforeEach {
                repository = FitnessLogRepository()
                info = FitnessInfo(weight: 66, height: 171, bodyFatPercentage: 0.19, musclePercentage: 0.345)
            }
            
            context("Storing items") {
                it("Can store and retrieve fitness data") {
                    let date = NSDate().timeIntervalSinceNow
                    expect(repository.save(date: date, record: info)).toNot(beNil())
                    
                    if let actual = repository.get(byDate: date) {
                        expect(info == actual.fitnessInfo).to(beTrue())
                    } else {
                        fail("The repository hasn't stored the value fitness info for the given date")
                    }
                }
            }
            
            context("Retrieving items") {
                it("Returns nil when the data for specific date is not stored") {
                    expect(repository.get(byDate: NSDate().timeIntervalSinceNow)).to(beNil())
                }
            }
            
            context("Deleting items") {
                it("Can delete fitness data") {
                    let date = NSDate().timeIntervalSinceNow
                    expect(repository.save(date: date, record: info)).toNot(beNil())
                    
                    let record = repository.get(byDate: date)
                    expect(record).toNot(beNil())
                    
                    let deleted = repository.delete(record: record!)
                    expect(deleted).toNot(beNil())
                    expect(info == deleted!.fitnessInfo).to(beTrue())
                    
                    expect(repository.get(byDate: date)).to(beNil())
                }
                
                it("Returns nil when deleting an unexisting record") {
                    let unexistingRecord = StoredFitnessInfo(date: NSDate().timeIntervalSinceNow, fitnessInfo: info)
                    
                    expect(repository.delete(record: unexistingRecord)).to(beNil())
                }
            }
        }
    }
}
