//
//  DrawingViewController.swift
//  Drawing-macOS
//
//  Created by Jacob Martin on 6/9/18.
//  Copyright © 2018 jjm. All rights reserved.
//

import Cocoa
import MetalKit
import DrawingKit_macOS

// Our macOS specific view controller
class DrawingViewController: NSViewController {
    
    lazy var drawingView: DrawingView = {
        DrawingView(frame: view.bounds)
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let v = NSView()
        self.view = v
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        guard let functions = DrawingManager.linearDrawing else { return }
        
        view.addSubview(drawingView)
        
        let floatMappedRange = (-2...2)
//            .reversed()
            .map({Float($0)/3.0})
        let vectorMappedRange = floatMappedRange.map({vector_float2($0,$0)})
        let touchMappedRange = vectorMappedRange.map({TouchInput(pos: $0)})
        
        touchMappedRange.forEach { (f) in
            
            drawingView.splineBuilder.augment(with: f)
            
        }
//        
       
        drawingView.draw()
    }
    
    //    override func mouseMoved(with event: NSEvent) {
    //        drawingView.mouseMoved(with: event)
    //    }
}
