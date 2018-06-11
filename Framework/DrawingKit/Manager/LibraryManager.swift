//
//  DrawingManager.swift
//  Drawing-iOS
//
//  Created by Jacob Martin on 6/8/18.
//  Copyright © 2018 jjm. All rights reserved.
//

import Foundation
import Metal

public typealias ShaderFunctions = (vertex: MTLFunction, fragment: MTLFunction)



private struct Config {
    var library: MTLLibrary?
    var device: MTLDevice?
}

private var config = Config()

public func configureDrawingShaderLibrary(library: MTLLibrary, device: MTLDevice) {
    config.library = library
    config.device = device
    
    _ = DrawingManager.linearDrawing
    
    print("configured library")
}

public class DrawingManager {
    
    var device = config.device
    
    public static let shared = DrawingManager()
    
    private init(){}
    
    public static var linearDrawing: ShaderFunctions? =  {
        
            guard let vertex = config.library?.makeFunction(name: "lineVertex"),
                let fragment = config.library?.makeFunction(name: "lineFragment") else {
                    
                    return nil }
            return ShaderFunctions(vertex: vertex, fragment: fragment)
    }()
}
