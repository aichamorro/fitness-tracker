//
//  UIGraphViewValuesAdapaterTests.swift
//  UIGraphView
//
//  Created by Alberto Chamorro on 27/01/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//
import XCTest
import UIKit
@testable import UIGraphView

class UIDispersionValuesAdapterTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testComputesCorrectlyTheRangeOfAnSetOfPoints() {
    }
}

extension Sequence where Iterator.Element: Comparable {
    func range() {
        let sortedSequence = self.sorted(by: <)
        
        return (min: sortedSequence.first!, max: sortedSequence.last)
    }
}
