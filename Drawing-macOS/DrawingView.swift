//
//  DrawingView.swift
//  Drawing-macOS
//
//  Created by Jacob Martin on 6/9/18.
//  Copyright © 2018 jjm. All rights reserved.
//

import Foundation
import DrawingKit_macOS

class DrawingView: MetalLineDrawingView {
    
    func drawTouch(_ touch: NSEvent){
        
        
        if splineBuilder.count > 100 {
            refreshBuffer()
        }
        
        
        let p = touch.locationInWindow
        let t = TouchInput(pos: p.vector)
        
        splineBuilder.augment(with: t, convertScale: convertToScale)
        
        
        draw()
    }
    
    override func mouseDragged(with event: NSEvent) {
        drawTouch(event)
    }
    
    override func mouseUp(with event: NSEvent) {
        refreshBuffer()
    }
    
}
