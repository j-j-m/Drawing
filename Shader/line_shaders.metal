//
//  linear_shaders.metal
//  CurvePaint
//
//  Created by Jacob Martin on 6/1/18.
//  Copyright © 2018 jjm. All rights reserved.
//

// File for Metal kernel and shader functions

#include <metal_stdlib>
#include <simd/simd.h>
#include "Simplex2D.metal"

// Including header shared between this Metal shader code and Swift/C code executing Metal API commands

using namespace metal;

struct VertIn {
    float4 position[[attribute(0)]];
};

struct VertOut {
    float4 position[[position]];
};

vertex VertOut lineVertex(constant VertIn *vertices [[ buffer(0) ]],
                               uint vertexId [[vertex_id]])
{
    VertOut out;
    VertIn v = vertices[vertexId];
    
    out.position = v.position;

    return out;
}

fragment float4 lineFragment(VertOut in [[stage_in]])
{
    //    constexpr sampler colorSampler(mip_filter::linear,
    //                                   mag_filter::linear,
    //                                   min_filter::linear);
    //
    //    half4 colorSample   = colorMap.sample(colorSampler, in.texCoord.xy);
    //
    //    return float4(colorSample);
    
    float2 s = in.position.xy;
    float f =  1.0 -
    snoise(s);
    float r = f;
    float g = f;
    float b = f;
    
    
    return float4(r,g,b,1.0);
}
