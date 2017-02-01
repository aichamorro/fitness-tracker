//
//  UIGraphViewDrawingStyles.swift
//  UIGraphView
//
//  Created by Alberto Chamorro on 29/01/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import QuartzCore

internal typealias UIGraphViewDrawingStyle = (_ context: CGContext, _ rect: CGRect, _ iterator: UIGraphViewValuesIterator, _ didDrawPoint: ((CGPoint, Int)->Void)?) -> Void
internal typealias UIGraphViewValuesIterator = (_ rect: CGRect, (_ point: CGPoint) -> Void) -> Void

struct UIGraphViewDrawingStyles {
    static func bars(barWidth: CGFloat, barColor: CGColor) -> UIGraphViewDrawingStyle {
        return { context, rect, iterator, didDrawPoint in
            let fillColor = barColor
            
            context.setFillColor(fillColor)
            context.setLineWidth(barWidth)
            context.setStrokeColor(fillColor)
            
            var index = 0
            iterator(rect) { point in
                context.strokeLineSegments(between: [point, CGPoint(x: point.x, y: rect.maxY)])
                context.fillCircle(center: point, radius: barWidth)
                didDrawPoint?(point, index)
                index += 1
            }
            
            context.strokePath()
            context.fillPath()
        }
    }
    
    static func points(pointRadius: CGFloat, color: UIColor, didDrawPoint: ((CGPoint) -> Void)? = nil) -> UIGraphViewDrawingStyle {
        return { context, rect, iterator, didDrawPoint in
            context.executeBatch { (context) in
                context.setFillColor(color.cgColor)
                
                // Graph
                let path = CGMutablePath()
                var isFirst = true
                var index = 0
                
                iterator(rect) { point in
                    if isFirst {
                        isFirst = false
                        path.move(to: point)
                    } else {
                        path.addLine(to: point)
                    }
                    
                    context.addCircle(center: point, radius: pointRadius)
                    didDrawPoint?(point, index)
                    index += 1
                }
                context.fillPath()
                
                context.addPath(path)
                context.setStrokeColor(color.cgColor)
                context.strokePath()

                // Gradients
                path.addLine(to: CGPoint(x: path.currentPoint.x, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.origin.x, y: rect.maxY))
                context.addPath(path)
                context.clip()
                let startColor = color.withAlphaComponent(0.5).cgColor
                let endColor = color.withAlphaComponent(0).cgColor
                context.drawLinearGradient(rect: rect, startColor: startColor, endColor: endColor)
            }
        }
    }
}
