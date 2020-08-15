//
//  CALayerExtension.swift
//  bm-persona
//
//  Created by Shawn Huang on 7/12/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

/// Functions to add text or a rounded rectangle to a layer
extension CALayer {
    func addTextLayer(frame: CGRect, color: CGColor, fontSize: CGFloat, text: String) {
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
    
    func addRoundedRectangleLayer(frame: CGRect, cornerRadius: CGFloat, color: CGColor) {
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(roundedRect: frame, cornerRadius: cornerRadius).cgPath
        layer.fillColor = color
        layer.strokeColor = color
        layer.lineWidth = 0.0
        self.addSublayer(layer)
    }
}
