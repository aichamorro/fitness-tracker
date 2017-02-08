//
//  UIGraphViewTests.swift
//  UIGraphViewTests
//
//  Created by Alberto Chamorro on 27/01/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import XCTest
import UIKit
@testable import UIGraphView

class UIGraphViewTests: XCTestCase {
    
    var dispersionGraph: UIGraphView!
    var fakeDataSource: FakeUIGraphViewDataSource!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        dispersionGraph = UIGraphView()
        fakeDataSource = FakeUIGraphViewDataSource()
        dispersionGraph.datasource = fakeDataSource
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCanSetTheDataSource() {
        dispersionGraph.datasource = fakeDataSource
        
        XCTAssertNotNil(dispersionGraph.datasource)
        XCTAssert(dispersionGraph.datasource! === fakeDataSource)
    }
    
    func testUsesTheDataSourceToGetTheData() {
        var didCallDataMethod = false

        fakeDataSource.dataForDispersionGraphClosure = { dispersionGraph in
            didCallDataMethod = true
            
            return UIGraphViewSampleData(horizontal: [], vertical: [])
        }
        
        dispersionGraph.setNeedsDisplay()
        XCTAssertTrue(didCallDataMethod)
    }
    
    func testFailsWhenTheNumberOfHoriontalAndVerticalValuesIsDifferent() {
        expectFatalError(expectedMessage: "The datasource provided, does not produce the expected data: number of horizontal and vertical items are different") {
            self.fakeDataSource.dataForDispersionGraphClosure = { graph in
                return UIGraphViewSampleData(horizontal: [1, 2, 3], vertical: [])
            }
            
            self.dispersionGraph.setNeedsDisplay()
        }
    }
}

class FakeUIGraphViewDataSource: UIGraphViewDataSource {
    var dataForDispersionGraphClosure: ((UIGraphView) -> UIGraphViewSampleData)?
    
    func data(for dispersionGraph: UIGraphView) -> UIGraphViewSampleData {
        return self.dataForDispersionGraphClosure!(dispersionGraph)
    }
}
