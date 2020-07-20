//
//  CALayerExtension.swift
//  bm-persona
//
//  Created by Shawn Huang on 7/12/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

extension CALayer {
    func addCurvedLayer(curvedSegment: CurvedSegment, color: CGColor, oldSegment: CurvedSegment?) {
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(curvedSegment: curvedSegment).cgPath
        layer.fillColor = color
        layer.strokeColor = color
        layer.lineWidth = 0.0
        self.addSublayer(layer)
    }
    
    func addTextLayer(frame: CGRect, color: CGColor, fontSize: CGFloat, text: String, oldFrame: CGRect?) {
        let textLayer = CATextLayer()
        textLayer.frame = frame
        textLayer.foregroundColor = color
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.alignmentMode = CATextLayerAlignmentMode.center
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.font = Font.light(fontSize)
        textLayer.fontSize = fontSize
        textLayer.string = text
        self.addSublayer(textLayer)
    }
    
    func addRectangleLayer(frame: CGRect, color: CGColor, oldFrame: CGRect?) {
        let layer = CALayer()
        layer.frame = frame
        layer.backgroundColor = color
        self.addSublayer(layer)
    }
}

extension UIBezierPath {
    convenience init(curvedSegment: CurvedSegment) {
        self.init()
        self.move(to: curvedSegment.startPoint)
        self.addCurve(to: curvedSegment.toPoint, controlPoint1: curvedSegment.controlPoint1, controlPoint2: curvedSegment.controlPoint2)
        self.addLine(to: curvedSegment.endPoint)
    }
    
    convenience init(lineSegment: LineSegment) {
        self.init()
        self.move(to: lineSegment.startPoint)
        self.addLine(to: lineSegment.endPoint)
    }
}

struct CurvedSegment {
    let startPoint: CGPoint
    let endPoint: CGPoint
    let toPoint: CGPoint
    let controlPoint1: CGPoint
    let controlPoint2: CGPoint
}

struct LineSegment {
    let startPoint: CGPoint
    let endPoint: CGPoint
}
