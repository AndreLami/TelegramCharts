//
//  IRenderSurfaceManager.swift
//  GraphPresenter
//
//  Created by Andre on 3/28/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation

class RenderSurfaceManager<RendererType> {
    
    private (set) weak var renderStage: RenderStage!
    
    func createRenderSurface(withParams params: RenderSurfaceParams<RendererType>) -> RenderSurface<RendererType> {
        fatalError()
    }
    
    func onAttachedToStage(stage: RenderStage) {
        self.renderStage = stage
    }
    
}
