//
//  ShaderTypes.swift
//  GraphPresenter
//
//  Created by Andre on 3/27/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import simd


let AAPLVertexInputIndexVertices = 0
let AAPLVertexInputIndexViewportSize = 1
let AAPLVertexInputIndexScreenSize = 2

struct ChartRenderVertex {
    
    var position: float2  = float2()
    
    var normal: float2 = float2()
    var nextNormal: float2 = float2()
    
    var direction: float2 = float2()
    
    var color: float4 = float4()
    
}
