//
//  ViewSurfaceManager.swift
//  GraphPresenter
//
//  Created by Andre on 3/28/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation

class ViewSurfaceManager: RenderSurfaceManager<IViewSurfaceRenderer> {
    
    override func createRenderSurface(withParams params: RenderSurfaceParams<IViewSurfaceRenderer>) -> RenderSurface<IViewSurfaceRenderer> {
        let surface = ViewRenderSurface.init(withIdentifier: params.identifier) { [weak self] () -> ViewSurfaceLayoutContext in
            let result = self?.createLayoutContext()
            return result!
        }
        
        return  surface
    }
}

private extension ViewSurfaceManager {
    
    func createLayoutContext() -> ViewSurfaceLayoutContext {
        return ViewSurfaceLayoutContext.init(viewPort: self.renderStage.currentViewPort,
                                             dimensionsConverter: self.renderStage.dimensionsConverter)
    }
    
}
