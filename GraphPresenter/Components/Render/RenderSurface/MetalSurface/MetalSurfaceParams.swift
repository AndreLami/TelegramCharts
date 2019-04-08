//
//  MetalSurfaceParams.swift
//  GraphPresenter
//
//  Created by Andre on 3/28/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation

class MetalSurfaceParams: RenderSurfaceParams<IMetalSurfaceRenderer> {
    
    let vertexFunction: String
    let fragmentFunction: String
    
    init(identifier: String, vertexFunction: String, fragmentFunction: String) {
        self.vertexFunction = vertexFunction
        self.fragmentFunction = fragmentFunction
        
        super.init(identifier: identifier)
    }
    
}
