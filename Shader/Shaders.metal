//
//  Shaders.metal
//  Drawing-iOS
//
//  Created by Jacob Martin on 6/6/18.
//  Copyright © 2018 jjm. All rights reserved.
//

// File for Metal kernel and shader functions

#include <metal_stdlib>
#include <simd/simd.h>
#include "Simplex2D.metal"

// Including header shared between this Metal shader code and Swift/C code executing Metal API commands
#import "../Shader/ShaderTypes.h"

using namespace metal;

typedef struct
{
    float3 position [[attribute(VertexAttributePosition)]];
    float2 texCoord [[attribute(VertexAttributeTexcoord)]];
} Vertex;

typedef struct
{
    float4 position [[position]];
    float2 texCoord;
} ColorInOut;

vertex ColorInOut vertexShader(Vertex in [[stage_in]],
                               constant Uniforms & uniforms [[ buffer(BufferIndexUniforms) ]])
{
    ColorInOut out;

    float4 position = float4(in.position, 1.0);
    out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * position;
    out.texCoord = in.texCoord;

    return out;
}

fragment float4 fragmentShader(ColorInOut in [[stage_in]],
                               constant Uniforms & uniforms [[ buffer(BufferIndexUniforms) ]],
                               texture2d<half> colorMap     [[ texture(TextureIndexColor) ]])
{
//    constexpr sampler colorSampler(mip_filter::linear,
//                                   mag_filter::linear,
//                                   min_filter::linear);
//
//    half4 colorSample   = colorMap.sample(colorSampler, in.texCoord.xy);
//
//    return float4(colorSample);
    
    float4 s = uniforms.modelViewMatrix * in.texCoord.xyxy;
    float r = noisy(s.xy);
    float g = noisy(s.yx);
    float b = snoise(s.xy);
    
    
    return float4(r,g,b,1.0);
}
