//
//  DrawingViewController.swift
//  Drawing-iOS
//
//  Created by Jacob Martin on 6/10/18.
//  Copyright © 2018 jjm. All rights reserved.
//

import UIKit
import MetalKit
import DrawingKit_iOS

// Our macOS specific view controller
class DrawingViewController: UIViewController {
    
    lazy var drawingView: DrawingView = {
        DrawingView(frame: view.bounds)
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewWillAppear(_ animated: Bool) {
  
        super.viewWillAppear(animated)
        
        guard let functions = DrawingManager.linearDrawing else { return }
        
        view.addSubview(drawingView)
        
        let floatMappedRange = (-3...2)
                        .reversed()
            .map({Float($0)/3.0})
        let vectorMappedRange = floatMappedRange.map({vector_float2($0,0)})
        let touchMappedRange = vectorMappedRange.map({TouchInput(pos: $0)})
        
        touchMappedRange.forEach { (f) in
            
            drawingView.splineBuilder.augment(with: f)
            
        }
        
        
        drawingView.draw()
    }
    
}
