//
//  RenderSurfaceDescriptor.swift
//  GraphPresenter
//
//  Created by Andre on 3/28/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation

class RenderSurfaceDescriptor<RendererType> {
    
    let rendererType: RendererType.Type
    
    init() {
        self.rendererType = RendererType.self
    }
    
    var describe: String {
        return String.init(describing: self.rendererType)
    }
}
