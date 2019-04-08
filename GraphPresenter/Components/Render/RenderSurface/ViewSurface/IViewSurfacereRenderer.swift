//
//  ViewSurfacereRerer.swift
//  GraphPresenter
//
//  Created by Andre on 3/28/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

class ViewSurfaceLayoutContext {
    
    let viewPort: ViewPort
    let dimensionsConverter: DimensionsConverter
    
    init(viewPort: ViewPort, dimensionsConverter: DimensionsConverter) {
        self.viewPort = viewPort
        self.dimensionsConverter = dimensionsConverter
    }
    
}


protocol IViewSurfaceRenderer: class {
    
    var zIndex: Int { get }
    
    func attachToContainer(_ container: UIView)
    func detachFromContainer()
    
    func layout(context: ViewSurfaceLayoutContext)
}
