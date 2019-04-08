//
//  MetalSurfaceManager.swift
//  GraphPresenter
//
//  Created by Andre on 3/28/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import MetalKit

class MetalSurfaceManager: RenderSurfaceManager<IMetalSurfaceRenderer> {
    
    override func createRenderSurface(withParams params: RenderSurfaceParams<IMetalSurfaceRenderer>) -> RenderSurface<IMetalSurfaceRenderer> {
        let metalParams = params as! MetalSurfaceParams
        let surface = MetalSurface.init(withIdentifier: metalParams.identifier,
                                        surfaceParams: metalParams)
        { [weak self] (view) -> MetalContext in
            return self!.createMetalContext(view)
        }
        
        return surface
    }

}

private extension MetalSurfaceManager {
    
    func createMetalContext(_ view: MTKView) -> MetalContext {
        return MetalContext.init(view: view,
                                 viewPort: self.renderStage.currentViewPort,
                                 dimensionsConverter: self.renderStage.dimensionsConverter)
    }
    
}
