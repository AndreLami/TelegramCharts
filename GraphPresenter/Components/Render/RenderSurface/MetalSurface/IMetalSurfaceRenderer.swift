//
//  IMetalSurfaceRenderer.swift
//  GraphPresenter
//
//  Created by Andre on 3/28/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import MetalKit

protocol IMetalSurfaceRenderer: class {
    
    func render(withEncoder encoder: MTLRenderCommandEncoder, context: MetalContext)
    func setupWithView(_ view: MTKView)
}

