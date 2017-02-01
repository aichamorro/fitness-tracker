//
//  UIGradientView.swift
//  UIGraphView
//
//  Created by Alberto Chamorro on 31/01/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation

@IBDesignable
final public class UIGradientView: UIView {
    
    @IBInspectable public var startColor: UIColor = UIColor.black.withAlphaComponent(0)
    @IBInspectable public var endColor: UIColor = UIColor.black.withAlphaComponent(0.6)
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if let context = UIGraphicsGetCurrentContext() {
            context.drawLinearGradient(rect: rect, startColor: startColor.cgColor, endColor: endColor.cgColor)
            
            UIGraphicsEndImageContext()
        }
    }
}
