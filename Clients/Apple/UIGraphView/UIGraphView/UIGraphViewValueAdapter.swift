//
//  UIGraphViewValueAdapter.swift
//  UIGraphView
//
//  Created by Alberto Chamorro on 28/01/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation

internal typealias UIGraphViewValueMapper = (_ rect: CGRect, _ horizontal: Double, _ vertical: Double) -> CGPoint
internal typealias UIGraphViewAxisValueMapper = (Double) -> Double

private func proportional(range: Range<Double>) -> UIGraphViewAxisValueMapper {
    let translation = range.lowerBound
    let rangeDistance = range.upperBound - range.lowerBound
    let factor = rangeDistance > 0 ? 1/rangeDistance : 1
    
    return { value in
        return (value - translation) * factor
    }
}

private func fillEqually(steps: Int) -> UIGraphViewAxisValueMapper {
    let factor = 1/Double(steps - 1)
    var index: Int = 0
    
    return { _ in
        let relativePosition = factor * Double(index)
        index = (index + 1) % steps

        return relativePosition
    }
}

internal struct UIGraphViewValueMapperFactory {
    private static func separateRangeBoundsIfNeeded(_ range: Range<Double>) -> Range<Double> {
        guard range.lowerBound == range.upperBound else { return range }
        
        return Range(uncheckedBounds: (range.lowerBound, range.upperBound + 0.5))
    }
    
    static func create(horizontalData: [Double], verticalData: [Double]) -> UIGraphViewValueMapper {
        let horizontalValueMapper = proportional(range: horizontalData.range!)
        let verticalValueMapper = proportional(range: separateRangeBoundsIfNeeded(verticalData.range!))
        
        return { rect, xValue, yValue in
            let horizontalPosition = rect.origin.x + CGFloat(horizontalValueMapper(xValue)) * rect.width
            let verticalPosition = (rect.origin.y + rect.height) - CGFloat(verticalValueMapper(yValue)) * rect.height
            
            return CGPoint(x: horizontalPosition, y: verticalPosition)
        }
    }
}
