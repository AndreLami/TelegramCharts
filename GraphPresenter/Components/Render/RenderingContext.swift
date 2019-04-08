//
//  GraphRenderingContext.swift
//  ChartPresenter
//
//  Created by Andre on 3/10/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit
import MetalKit

@objc class RenderingContext: NSObject {
    
    let drawContext: CGContext
    
    let dimensionsConverter: DimensionsConverter
    
    let viewPort: ViewPort
    
    init(drawContext: CGContext, viewPort: ViewPort, dimensionsConverter: DimensionsConverter) {
        self.drawContext = drawContext
        self.viewPort = viewPort
        self.dimensionsConverter = dimensionsConverter
    }

    
}

@objc class MetalContext: NSObject {
    
    @objc var view: MTKView
    
    @objc let dimensionsConverter: DimensionsConverter
    
    @objc let viewPort: ViewPort
    
    init(view: MTKView, viewPort: ViewPort, dimensionsConverter: DimensionsConverter) {
        self.view = view
        self.viewPort = viewPort
        self.dimensionsConverter = dimensionsConverter
    }
    
    
}
