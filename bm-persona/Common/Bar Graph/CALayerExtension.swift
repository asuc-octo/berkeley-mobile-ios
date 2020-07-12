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
    
    func addLineLayer(lineSegment: LineSegment, color: CGColor, width: CGFloat, isDashed: Bool, oldSegment: LineSegment?) {
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(lineSegment: lineSegment).cgPath
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = color
        layer.lineWidth = width
        if isDashed {
            layer.lineDashPattern = [4, 4]
        }
        self.addSublayer(layer)
    }
    
    func addTextLayer(frame: CGRect, color: CGColor, fontSize: CGFloat, text: String, oldFrame: CGRect?) {
        let textLayer = CATextLayer()
        textLayer.frame = frame
        textLayer.foregroundColor = color
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.alignmentMode = CATextLayerAlignmentMode.center
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
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
