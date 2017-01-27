//
//  UIDispersionGraph.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro on 26/01/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import UIKit
import QuartzCore

typealias BidimensionalValuesContainer = (x: [Double], y: [Double])

protocol UIDispersionGraphDelegate: class {
    func values(for: UIDispersionGraph) -> BidimensionalValuesContainer
}

@IBDesignable
final class UIDispersionGraph: UIView {
    weak var delegate: UIDispersionGraphDelegate?
    
    @IBInspectable var lineColor: UIColor = UIColor.blue
    @IBInspectable var lineWidth: CGFloat = 2
    
    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: 0, y: rect.height)
            context.setStrokeColor(lineColor.cgColor)
            context.setLineWidth(lineWidth)
            
            context.strokeLineSegments(between: [origin, CGPoint(x: origin.x, y: 0)])
            context.strokeLineSegments(between: [origin, CGPoint(x: rect.width, y: origin.y)])

            if let delegate = delegate {
                let values = delegate.values(for: self)
                
                // let horizontalRange =
                // let verticalRange =
            }
            
            UIGraphicsEndImageContext()
        }
    }
}
