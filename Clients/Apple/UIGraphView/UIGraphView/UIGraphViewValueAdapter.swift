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
    let factor = 1/(range.upperBound - range.lowerBound)
    
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
    static func create(horizontalRange: [Double], verticalRange: [Double]) -> UIGraphViewValueMapper {
        let horizontalValueMapper = fillEqually(steps: horizontalRange.count)
        let verticalValueMapper = proportional(range: verticalRange.range!)
        
        return { rect, xValue, yValue in
            let horizontalPosition = rect.origin.x + CGFloat(horizontalValueMapper(xValue)) * rect.width
            let verticalPosition = (rect.origin.y + rect.height) - CGFloat(verticalValueMapper(yValue)) * rect.height
            
            return CGPoint(x: horizontalPosition, y: verticalPosition)
        }
    }
}
