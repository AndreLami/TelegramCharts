//
//  RenderSurfaceParams.swift
//  GraphPresenter
//
//  Created by Andre on 3/28/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation

class RenderSurfaceParams<RendererType> {
    
    let identifier: String
    let descriptor = RenderSurfaceDescriptor<RendererType>()
    var zIndex: Int = 0
    
    
    init(identifier: String) {
        self.identifier = identifier
    }
    
}
