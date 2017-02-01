//
//  QuartzCore.swift
//  UIGraphView
//
//  Created by Alberto Chamorro on 29/01/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation

extension CGPoint {
    func adding(toY value: CGFloat) -> CGPoint {
        return CGPoint(x: self.x, y: self.y + value)
    }
    
    func adding(toX value: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + value, y: self.y)
    }
}

public extension CGContext {
    func fillCircle(center: CGPoint, radius: CGFloat) {
        addCircle(center: center, radius: radius)
        fillPath()
    }
    
    func addCircle(center: CGPoint, radius: CGFloat) {
        let rect = CGRect(origin: CGPoint(x: center.x - radius/2, y: center.y - radius/2), size: CGSize(width: radius, height: radius))
        
        addEllipse(in: rect)
    }
    
    func executeBatch(_ operations: (CGContext) -> Void) {
        self.saveGState()
        operations(self)
        self.restoreGState()
    }
    
    func drawLinearGradient(rect: CGRect, startColor: CGColor, endColor: CGColor) {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [0.0, 1.0]
        let colors = [startColor, endColor]
        
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)
        let startPoint = CGPoint(x: rect.midX, y: rect.minY)
        let endPoint = CGPoint(x: rect.midX, y: rect.maxY)

        addRect(rect)
        drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: [])
    }
}

extension CGRect {
    func reducedAndCenterd(xFactor: CGFloat, yFactor: CGFloat) -> CGRect {
        let graphWidth = self.width * min(xFactor, 1.0)
        let graphHeight = self.height * min(yFactor, 1.0)
        let sideSpace = (self.width - graphWidth) / 2
        let verticalSpace = (self.height - graphHeight) / 2
        
        return CGRect(x: self.origin.x + sideSpace,
                      y: self.origin.y + verticalSpace,
                      width: graphWidth,
                      height: graphHeight)
    }
    
    func reducedHeight(by height: CGFloat) -> CGRect {
        return CGRect(origin: self.origin, size: CGSize(width: self.width, height: self.height - height))
    }
}
