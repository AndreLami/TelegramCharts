//
//  CGRenderSurfaceManager.swift
//  GraphPresenter
//
//  Created by Andre on 3/28/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

class CGSurfaceManager: RenderSurfaceManager<ICGSurfaceRenderer> {
    
    override func createRenderSurface(withParams params: RenderSurfaceParams<ICGSurfaceRenderer>) -> RenderSurface<ICGSurfaceRenderer> {
        let surface = CGRenderSurface.init(withIdentifier: params.identifier) { [weak self] (context) -> RenderingContext in
            let result = self?.createRenderContext(drawContext: context)
            return result!
        }
        
        return  surface
    }
}

private extension CGSurfaceManager {
    
    func createRenderContext(drawContext: CGContext) -> RenderingContext {
        return RenderingContext.init(drawContext: drawContext,
                                     viewPort: self.renderStage.currentViewPort,
                                     dimensionsConverter: self.renderStage.dimensionsConverter)
    }
    
}
