//
//  DrawingView.swift
//  Drawing-iOS
//
//  Created by Jacob Martin on 6/8/18.
//  Copyright © 2018 jjm. All rights reserved.
//

import Foundation
import DrawingKit_iOS

class DrawingView: MetalLineDrawingView {
    func drawTouches(_ touches: Set<UITouch>){
        
     
        if splineBuilder.count > 100 {
            refreshBuffer()
        }
        
        for touch in touches {
            let p = touch.preciseLocation(in: self)
            let t = TouchInput(pos: p.vector)
            splineBuilder.augment(with: t, convertScale: convertToScale)

        }
        
//        draw()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        drawTouches(touches)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // when is this called w/ nil touches?
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        refreshBuffer()
    }
    
    override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
        
    }
}
