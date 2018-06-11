//
//  MetalLineDrawingView.swift
//  CurvePaint
//
//  Created by Jacob Martin on 6/1/18.
//  Copyright © 2018 jjm. All rights reserved.
//

#if os(OSX)
import Cocoa
typealias View = NSView
#elseif os(iOS)
import UIKit
typealias View = UIView
#endif

import MetalKit


private let maxBufferCount = 3

extension CGPoint {
    public var vector: vector_float2 {
        return vector_float2(x: Float(self.x), y: Float(self.y))
    }
}


public struct TouchInput
{
    // Set coordinateRange to <1.0 to restrict the drawing area
    static let coordinateRange : Float = 1.0
    
    public var position: vector_float2 = vector_float2()
    var normal: vector_float2 = vector_float2()
    var tangent: vector_float2 = vector_float2()
    
    var lineWidth: Float = 0.01
    
    var color : vector_float4 = vector_float4()
    
    var head: simd_bool = false
    var tail: simd_bool = false
    
    var nPosition: vector_float2 = vector_float2()
    var nNormal: vector_float2 = vector_float2()
    var nTangent: vector_float2 = vector_float2()
    
    public init(pos : vector_float2) {
        color = vector_float4(x: Float(arc4random_uniform(1000)) / 1000.0,
                              y: Float(arc4random_uniform(1000)) / 1000.0,
                              z: Float(arc4random_uniform(1000)) / 1000.0,
                              w: 1.0)
        //        color = vector_float4(x: 1.0,
        //                              y: 1.0,
        //                              z: 1.0,
        //                              w: 1.0)
        self.position = pos
    }
}

open class MetalLineDrawingView: MTKView {
    
    private var commandQueue: MTLCommandQueue! = nil
    private var library: MTLLibrary! = nil
    private var pipelineDescriptor = MTLRenderPipelineDescriptor()
    private var pipelineState : MTLRenderPipelineState! = nil
    private var vertexBuffer : MTLBuffer! = nil
    
    let inFlightSemaphore = DispatchSemaphore(value: maxBufferCount)
    
    // This is where we store all curve parameters. We use the PageAlignedContiguousArray to directly store and manipulate
    // them in shared memory.
    public var splineBuilder = SplineBuilder()
    
    public init(frame: CGRect)
    {
        let device = DrawingManager.shared.device
        super.init(frame: frame, device: device)
        configureWithDevice(device!)
    }
    
    required public init(coder: NSCoder)
    {
        super.init(coder: coder)
        guard let device = DrawingManager.shared.device else { return }
        configureWithDevice(device)
    }
    
    private func configureWithDevice(_ device : MTLDevice) {
        self.clearColor = MTLClearColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        //        self.autoresizingMask = [View.AutoresizingMask.flexibleWidth, View.AutoresizingMask.flexibleHeight]
        self.framebufferOnly = true
        self.colorPixelFormat = .bgra8Unorm
        
        // Run with 4x MSAA:
        self.sampleCount = 4
        
        self.preferredFramesPerSecond = 60
        
        self.device = device
        
//        self.isPaused = true
    }
    
    override open var device: MTLDevice! {
        didSet {
            super.device = device
            commandQueue = (self.device?.makeCommandQueue())!
            
            pipelineDescriptor.vertexFunction = DrawingManager.linearDrawing?.vertex
            pipelineDescriptor.fragmentFunction = DrawingManager.linearDrawing?.fragment
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
          

            
            // Run with 4x MSAA:
            pipelineDescriptor.sampleCount = self.sampleCount
            
            do {
                try pipelineState = device?.makeRenderPipelineState(descriptor: pipelineDescriptor)
            }
            catch {
                print(error)
            }
            
        }
    }
    
    open func refreshBuffer() {

//       splineBuilder.flush()
    }
    
    override open func draw(_ rect: CGRect) {
        
        _ = inFlightSemaphore.wait(timeout: DispatchTime.distantFuture)
        
        guard splineBuilder.count > 0 else { return }
        guard let drawable = self.currentDrawable else {
            print("unable to get drawable")
            return
        }
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        
        let semaphore = inFlightSemaphore
        commandBuffer.addCompletedHandler { (_ commandBuffer)-> Swift.Void in
            semaphore.signal()
        }
        
        
        let renderPassDescriptor = self.currentRenderPassDescriptor
        
        if renderPassDescriptor == nil {
            return
        }
        
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor!)
        
        renderEncoder?.setRenderPipelineState(pipelineState)
        
        renderEncoder?.setVertexBuffer(splineBuilder.buffer, offset: 0, index: 0)
        
        // Enable this to see the actual triangles instead of a solid curve:
//        renderEncoder?.setTriangleFillMode(.lines)
        
        renderEncoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: splineBuilder.count)
        
        renderEncoder?.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
    }
}


extension MetalLineDrawingView {
    
    public func convertToScale(_ touch: inout TouchInput) {
        let w = Float(self.bounds.width)
        let h = Float(self.bounds.height)
        
        let s = vector_float2(w/2, h/2)
        touch.position.x = touch.position.x - s.x
        
        #if os(OSX)
        touch.position.y = touch.position.y - s.y
        #elseif os(iOS)
        touch.position.y = h - touch.position.y - s.y
        #endif
        
        touch.position = touch.position / (s)
        
    }
}
