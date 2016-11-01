//
//  GraphView.swift
//  Calculator
//
//  Created by Simen Gangstad on 30.10.2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import UIKit

protocol Graphable {
    
    func yValue(x: Double) -> Double
}

@IBDesignable class GraphView: UIView {

    private var axesDrawer = AxesDrawer()
    private var internalPosition = CGPoint(x: 0.0, y: 0.0)
    private var internalAmountOfPointsShownOnAxisPerUnit = CGFloat(10.0)
    
    public var graphPointsPerUnit = 100
    
    public var delegate: Graphable?
    
    @IBInspectable var position : CGPoint {
        set {
            
            internalPosition = newValue
            setNeedsDisplay()
        }
        get { return internalPosition }
    }
    
    @IBInspectable var amountOfPointsShownOnAxisPerUnit : CGFloat {
        set {
            internalAmountOfPointsShownOnAxisPerUnit = newValue
            setNeedsDisplay()
        }
        get { return internalAmountOfPointsShownOnAxisPerUnit }
    }
    
    private var interval : Double { get { return Double(bounds.width) / Double(graphPointsPerUnit) } }
    private var scale : Double?
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        axesDrawer.contentScaleFactor = contentScaleFactor
        let origin = CGPoint(x: rect.origin.x + rect.width / 2.0 + position.x, y: rect.origin.y + rect.height / 2.0 + position.y)
        axesDrawer.drawAxesInRect(bounds: rect, origin: origin, pointsPerUnit: amountOfPointsShownOnAxisPerUnit)
        
        let path = UIBezierPath()
        
        UIColor.blue.set()
        path.lineWidth = 2.0
    
        let range = Double(axesDrawer.endX! - axesDrawer.startX!)
        let interval : Double = range / Double(graphPointsPerUnit)
        scale = Double(bounds.width) / range
        
        let start = Double(Int(Double(axesDrawer.startX!) - interval - range * 0.25))
        let end = Double(axesDrawer.endX!) + range * 0.25
        path.move(to: getPointFromXValue(x: start))
        
        for var index in stride(from: start, through: end, by: interval) {
                        
            let point = getPointFromXValue(x: index)
            path.addLine(to: point)
            path.move(to: point)
        }
        
        path.stroke()
    }
    
    private func getPointFromXValue(x xValue: Double) -> CGPoint {
        
        let yValue = delegate?.yValue(x: xValue) ?? 0.0
        
        let x = xValue * scale! + Double(bounds.width / CGFloat(2.0)) + Double(position.x)
        let y = Double.abs((yValue * scale! + Double(bounds.height / 2.0) - Double(position.y)) - Double(bounds.height))
        
        return CGPoint(x: x, y: y)
    }
}
