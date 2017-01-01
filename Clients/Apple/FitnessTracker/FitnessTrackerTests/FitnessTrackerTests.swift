//
//  FitnessTrackerTests.swift
//  FitnessTrackerTests
//
//  Created by Alberto Chamorro - Personal on 13/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Quick
import Nimble
@testable import FitnessTracker

class WeightTrackerSpec: QuickSpec {
    override func spec() {
        describe("As user would like to be able to add my weight") {
            let currentInfo = FitnessInfo(weight: 70, height: 171, bodyFatPercentage: 18.8, musclePercentage: 34.7, waterPercentage: 43.0)

            it("Can record the actual weight") {
                expect(currentInfo.weight).to(equal(70))
                expect(currentInfo.height).to(equal(171))
                expect(currentInfo.bodyFatPercentage).to(equal(18.8))
                expect(currentInfo.musclePercentage).to(equal(34.7))
                expect(currentInfo.waterPercentage).to(equal(43.0))
            }
            
            context("Body stats") {
                it("Can calculate the weight of the body fat") {
                    expect(currentInfo.bodyFatWeight).to(equal(13.16))
                }
                
                it("Can calculate the lean body weight") {
                    expect(currentInfo.leanBodyWeight).to(equal(56.84))
                }
                
                it("Can calculate the muscle weight") {
                    expect(abs(currentInfo.muscleWeight - 24.29) < 0.0000001).to(beTrue())
                }
                
                it("Can calculate the water weight") {
                    expect(abs(currentInfo.waterWeight - 30.1) < 0.0000001).to(beTrue())
                }
                
                it("Can calculate the BMI") {
                    let isBMICorrect = abs(23.9389897746 - currentInfo.bmi) <= 0.0000001
                        
                    expect(isBMICorrect).to(beTrue())
                }
                
                context("BMI Rating") {
                    // http://www.bariatric-surgery-source.com/how-to-calculate-bmi.html#How_to_Calculate_BMI-Main
                    
                    it("Can rate the bmi correctly for underweight") {
                        expect(BMIRating.for(bmi: 0)).to(equal(BMIRating.underweight))
                        expect(BMIRating.for(bmi: 16)).to(equal(BMIRating.underweight))
                        expect(BMIRating.for(bmi: 18.499)).to(equal(BMIRating.underweight))
                    }
                    
                    it("Can rate the bmi correctly for healthyweight") {
                        expect(BMIRating.for(bmi: 18.5)).to(equal(BMIRating.healthyweight))
                        expect(BMIRating.for(bmi: 21.99)).to(equal(BMIRating.healthyweight))
                        expect(BMIRating.for(bmi: 24.99)).to(equal(BMIRating.healthyweight))
                    }
                    
                    it("Can rate the bmi correctly for overweight") {
                        expect(BMIRating.for(bmi: 25.0)).to(equal(BMIRating.overweight))
                        expect(BMIRating.for(bmi: 27.5)).to(equal(BMIRating.overweight))
                        expect(BMIRating.for(bmi: 29.99)).to(equal(BMIRating.overweight))
                    }

                    it("Can rate the bmi correctly for obese") {
                        expect(BMIRating.for(bmi: 30.0)).to(equal(BMIRating.obese))
                        expect(BMIRating.for(bmi: 32.99)).to(equal(BMIRating.obese))
                        expect(BMIRating.for(bmi: 34.99)).to(equal(BMIRating.obese))
                    }

                    it("Can rate the bmi correctly for severely obese") {
                        expect(BMIRating.for(bmi: 35.0)).to(equal(BMIRating.severelyObese))
                        expect(BMIRating.for(bmi: 39.89)).to(equal(BMIRating.severelyObese))
                        expect(BMIRating.for(bmi: 39.99)).to(equal(BMIRating.severelyObese))
                    }
                    
                    it("Can rate the bmi correctly for morbidly obese") {
                        expect(BMIRating.for(bmi: 40.0)).to(equal(BMIRating.morbidlyObese))
                        expect(BMIRating.for(bmi: 40.1)).to(equal(BMIRating.morbidlyObese))
                        expect(BMIRating.for(bmi: 49.89)).to(equal(BMIRating.morbidlyObese))
                    }

                    it("Can rate the bmi correctly for super obese") {
                        expect(BMIRating.for(bmi: 50.0)).to(equal(BMIRating.superObese))
                        expect(BMIRating.for(bmi: 51.0)).to(equal(BMIRating.superObese))
                        expect(BMIRating.for(bmi: 75.0)).to(equal(BMIRating.superObese))
                    }

                }
            }
        }
    }
}
