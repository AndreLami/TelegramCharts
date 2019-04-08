/*
See LICENSE folder for this sample’s licensing information.

This is adopted metal shaders file from apple
*/

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

#import "ShaderTypes.h"


typedef struct
{
    
    float4 clipSpacePosition [[position]];

    float4 color;

} RasterizerData;

typedef struct
{
    // Positions in pixel space (i.e. a value of 100 indicates 100 pixels from the origin/center)
    vector_float2 position;
    vector_float2 normal;
    vector_float2 nextNormal;
    vector_float2 direction;
    
    // Floating point RGBA colors
    vector_float4 color;
} AAPLVertex;

// Vertex Function
vertex RasterizerData
vertexShader(uint vertexID [[ vertex_id ]],
             device AAPLVertex *vertices [[ buffer(AAPLVertexInputIndexVertices) ]],
             constant vector_int4 *viewportSizePointer  [[ buffer(AAPLVertexInputIndexViewportSize) ]],
             constant vector_int2 *screenSizePointer  [[ buffer(AAPLVertexInputIndexScreenSize) ]])
{
    RasterizerData out;

    out.clipSpacePosition = vector_float4(0.0, 0.0, 0.0, 1.0);

    
    float2 pixelSpacePositionFull = vertices[vertexID].position.xy;
    float2 pixelSpacePosition = pixelSpacePositionFull.xy;
    
    float2 currentNormal = vertices[vertexID].normal;
    float2 nextNormal = vertices[vertexID].nextNormal;
    float direction = vertices[vertexID].direction.x;
    
    
    vector_float4 viewport = vector_float4(*viewportSizePointer);
    vector_float2 viewportSize = vector_float2(viewport.z - viewport.x, viewport.w - viewport.y);
    
    vector_float2 screenSize = vector_float2(*screenSizePointer);
    
    
    pixelSpacePosition -= viewport.xy;
    
    float2 positionScaler = viewportSize;
    float2 screenScaler = screenSize;

    float width = 1.5;
    
    currentNormal /= positionScaler.yx;
    nextNormal /= positionScaler.yx;

    currentNormal *= screenScaler.yx;
    nextNormal *= screenScaler.yx;

    currentNormal = normalize(currentNormal);
    nextNormal = normalize(nextNormal);
    
    float2 miter = normalize(currentNormal + nextNormal);

    float miterOffset = width / dot(miter, currentNormal);
    float2 resultOffset = miter * miterOffset;
    
    pixelSpacePosition /= positionScaler;
    pixelSpacePosition = pixelSpacePosition * 2 - 1.0;
    
    pixelSpacePosition *= screenScaler;
    pixelSpacePosition += resultOffset * direction;
    pixelSpacePosition /= screenScaler;
    
    out.clipSpacePosition.xy = pixelSpacePosition;
    out.color = vertices[vertexID].color;

    return out;
}

// Fragment function
fragment float4 fragmentShader(RasterizerData in [[stage_in]])
{
    // We return the color we just set which will be written to our color attachment.
    return in.color;
}

