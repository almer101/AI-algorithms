//
//  PointsView.swift
//  Slagalica
//
//  Created by Ivan Almer on 13/08/2019.
//  Copyright © 2019 ialmer. All rights reserved.
//

import UIKit

class PointsView: UIView {
    
    private var locations: [CGPoint] = []
    
    func updateLocations(_ locations: [CGPoint]) {
        self.locations = locations
        
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        drawLocations(locations: locations)
    }
    
    func drawAntPath(path: [CGPoint]) {
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        drawLocations(locations: locations)
        
        for i in 1..<path.count {
            drawLine(point1: path[i - 1], point2: path[i])
        }
    }
    
    func drawLocations(locations: [CGPoint]) {
        for location in locations {
            let pointPath = UIBezierPath(arcCenter: location, radius: 5, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
            let shapeLayer = CAShapeLayer()
            
            shapeLayer.path = pointPath.cgPath
            shapeLayer.fillColor = UIColor.white.cgColor
            
            layer.addSublayer(shapeLayer)
        }
    }
    
    private func drawLine(point1: CGPoint, point2: CGPoint) {
        let linePath = UIBezierPath()
        linePath.move(to: point1)
        linePath.addLine(to: point2)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = linePath.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        
        layer.addSublayer(shapeLayer)
    }

}
