//
//  UIGraphView.swift
//  UIGraphView
//
//  Created by Alberto Chamorro on 28/01/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import UIKit
import QuartzCore

public typealias UIGraphViewSampleData = (horizontal: [Double], vertical: [Double])

public protocol UIGraphViewDataSource: class {
    func data(for dispersionGraph: UIGraphView) -> UIGraphViewSampleData
}

public protocol UIGraphViewDelegate: class {
    func graphView(_ graphView: UIGraphView, shouldAddHorizontalTagFor index: Int) -> Bool
}

public extension UIGraphViewDelegate {
    func graphView(_ graphView: UIGraphView, shouldAddHorizontalTagFor index: Int) -> Bool {
        return true
    }
}

@IBDesignable
final public class UIGraphView: UIView {
    
    @IBInspectable public var lineColor: UIColor = UIColor.black
    @IBInspectable public var lineWidth: CGFloat = 2.0
    @IBInspectable public var font: UIFont = UIFont.systemFont(ofSize: 10)

    fileprivate var drawingFunction: UIGraphViewDrawingStyle!
    fileprivate var dataMapper: UIGraphViewValuesIterator?
    var verticalMinValue: NSString!
    var verticalMaxValue: NSString!
    var textAttributes: [String:Any]!
    var horizontalTags: [String]!
    
    weak public var datasource: UIGraphViewDataSource? {
        didSet {
            reloadData()
        }
    }
    
    weak public var delegate: UIGraphViewDelegate? {
        didSet {
            reloadData()
        }
    }
    
    public func reloadData() {
        guard let data = datasource?.data(for: self) else { return }
        
        if data.horizontal.count != data.vertical.count {
            fatalError("The datasource provided, does not produce the expected data: number of horizontal and vertical items are different")
        }
        
        guard let horizontalRange = data.horizontal.range, let verticalRange = data.vertical.range else {
            verticalMaxValue = ""
            verticalMinValue = ""
            
            return
        }
        
        // Graph Info
        verticalMinValue = String(format: "%.2f", verticalRange.lowerBound) as NSString
        verticalMaxValue = String(format: "%.2f", verticalRange.upperBound) as NSString
        horizontalTags = data.horizontal.map { String(format: "%.0f", $0) }
        
        // From value to pixel
        let mappingFunction = UIGraphViewValueMapperFactory.create(horizontalRange: data.horizontal, verticalRange: data.vertical)
        dataMapper = { rect, operation in zip(data.horizontal, data.vertical).forEach { operation(mappingFunction(rect, $0, $1)) } }
        drawingFunction = UIGraphViewDrawingStyles.points(pointRadius: 4, color: UIColor.white)
        
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = .center
        
        textAttributes = [
            NSFontAttributeName: font,
            NSParagraphStyleAttributeName: textStyle,
            NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.8)]
        
        setNeedsDisplay()
    }
}

extension UIGraphView {
    override public func draw(_ rect: CGRect) {
        super.draw(rect)

        if let context = UIGraphicsGetCurrentContext() {
            let graphRect = rect.reducedHeight(by: 20).reducedAndCenterd(xFactor: 0.8, yFactor: 1)

            // Draw reference lines
            context.setStrokeColor(UIColor.white.withAlphaComponent(0.3).cgColor)
            context.move(to: CGPoint(x: rect.minX, y: graphRect.maxY))
            context.addLine(to: CGPoint(x: rect.maxX, y: graphRect.maxY))
            context.move(to: CGPoint(x: rect.minX, y: graphRect.minY))
            context.addLine(to: CGPoint(x: rect.maxX, y: graphRect.minY))
            context.strokePath()

            context.executeBatch { context in
                context.setLineCap(.round)
                context.setLineDash(phase: 0, lengths: [3])
                context.move(to: CGPoint(x: rect.minX, y: graphRect.midY))
                context.addLine(to: CGPoint(x: rect.maxX, y: graphRect.midY))
                context.strokePath()
            }
            
            if let dataMapper = dataMapper {
                // Draw max and min values
                verticalMaxValue.draw(at: CGPoint(x: rect.minX + 5, y: graphRect.minY + 5), withAttributes: textAttributes)
                verticalMinValue.draw(at: CGPoint(x: rect.minX + 5, y: graphRect.maxY - 15), withAttributes: textAttributes)

                let horizontalTagHeight = (rect.maxY - graphRect.maxY)/4
                // Draw graph and horiontal tags
                drawingFunction(context, graphRect, dataMapper) { point, index in
                    if self.delegate?.graphView(self, shouldAddHorizontalTagFor: index) ?? true {
                        self.horizontalTags[index].draw(at: CGPoint(x: point.x - 5, y: graphRect.maxY + horizontalTagHeight), withAttributes: self.textAttributes)
                    }
                }
            }

            UIGraphicsEndImageContext()
        }
    }
}
