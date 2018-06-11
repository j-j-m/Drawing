//
//  LineBuilder.swift
//  Drawing-iOS
//
//  Created by Jacob Martin on 6/10/18.
//  Copyright © 2018 jjm. All rights reserved.
//

import Foundation
import Metal
import simd

private extension Array {
    func fromLast(_ i: Int) -> Element {
        return self[count - 1 - i]
    }
}

public struct VertIn {
    let position: float4
}

extension float2 {
    var vertIn: VertIn {
        let inter = float4(self.x, self.y, 0, 1)
        return VertIn(position: inter)
    }
}

public class SplineBuilder {
    
    public var points = [TouchInput]()
    public var vertices : PageAlignedContiguousArray<VertIn> = PageAlignedContiguousArray<VertIn>()
    
    public func augment(with t: TouchInput, convertScale: ((inout TouchInput) -> Void)? = nil) {
        
        var newTouch = t
        if let convert = convertScale {
            convert(&newTouch)
        }
        
        let position = newTouch.position
        let lineWidth = newTouch.lineWidth / 2
        
        var tA = position + float2(0,lineWidth)
        var tB = position - float2(0,lineWidth)
        
        defer {
            points.append(newTouch)
            
            vertices.append(contentsOf: [tA.vertIn,tB.vertIn])
            print(vertices.count)
            if let device = DrawingManager.shared.device {
                buffer = device.makeBufferWithPageAlignedArray(vertices)
            }
        }
        
        guard points.count > 0 else { return }
        
        let p1 = points.last!.position
        let p2 = newTouch.position
        
        guard points.count > 1 else {
            let pF = points[0]
            
            let newTangent = normalize(p2 - p1)
            let newNormal = vector_float2(-newTangent.y, newTangent.x)
            
            tA = position + newNormal * lineWidth
            tB = position - newNormal * lineWidth
            
            vertices[0] = (pF.position + newNormal * lineWidth).vertIn
            vertices[1] = (pF.position - newNormal * lineWidth).vertIn
            
            return
        }
        
        let p0 = points.fromLast(1).position
        
        let augmentTangent = normalize( normalize(p2 - p1) + normalize(p1 - p0) )
        let augmentNormal = vector_float2(-augmentTangent.y, augmentTangent.x)
        
        tA = position + augmentNormal * lineWidth
        tB = position - augmentNormal * lineWidth
        
    }
    
    public func flush() {
        points = [TouchInput]()
        vertices = PageAlignedContiguousArray<VertIn>()
    }
    
    public var count: Int {
        return vertices.count
    }
    
    public private(set) var buffer: MTLBuffer?
}
