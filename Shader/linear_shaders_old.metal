//
//  linear_shaders.metal
//  CurvePaint
//
//  Created by Jacob Martin on 6/1/18.
//  Copyright © 2018 jjm. All rights reserved.
//

#include <metal_stdlib>
#include <metal_texture>

using namespace metal;

struct StrokeRenderParameters
{
    uint inputCount;
};

// BezierParameters represent a per-curve buffer specifying curve parameters. Note that
// even though the vertex shader is obviously called per-vertex, it actually uses the same
// BezierParameters instance (identified through the instance_id) for all vertexes in a given
// curve.
struct TouchInput
{
    float2 position;
    float2 normal;
    float2 tangent;
    
    float lineThickness;
    float4 color;
    
    bool head;
    bool tail;
    
    float2 nPosition;
    float2 nNormal;
    float2 nTangent;
};

struct VertexOut {
    uint uID;
    uint vID;
    float2 tangent;
    float4 position[[position]];
    float4 color;
};

VertexOut cleanVertex(uint instanceId,
                      uint vertexId) {
    // prep initial vertex
    VertexOut vo;
    vo.uID = instanceId;
    vo.vID = vertexId;
    // w controls the zoom level (distance from viewport)
    vo.position.xy = float2(0.0, 0.0);
    vo.position.zw = float2(0, 1);
    vo.tangent = float2(0.0,0.0);
    
    return vo;
}

VertexOut interiorPoint(device TouchInput *allInput,
                        uint instanceId,
                        uint vertexId) {
    // prep initial vertex
    VertexOut vo = cleanVertex(instanceId, vertexId);
    
    int t = vertexId % 3;
    bool parity = (t % 2 == 0);

    TouchInput pA = allInput[instanceId];
    
    if (pA.tail == true) {
        return vo;
    }
    
    float2 p0 = pA.position;
    float2 p1 = pA.nPosition;
    
    float dir = (1 - (((float) (vertexId % 2)) * 2.0));
    vo.color = pA.color;
    float lineWidth = dir * pA.lineThickness * 2.0;
    vo.position.xy = (parity ? p0 : p1) +  (parity ? pA.normal : pA.nNormal) * lineWidth;
    
    return vo;
}

vertex VertexOut linear_vertex(device TouchInput *allInput[[buffer(0)]],
                               uint vertexId [[vertex_id]],
                               uint instanceId [[instance_id]])
{
    return interiorPoint(allInput, instanceId, vertexId);
}

//MARK: - Fragment Shader

fragment half4 linear_fragment(VertexOut params[[stage_in]])
{
 
    float4 c = params.color;
    c.w = 0.1;
    return half4(c);
}
