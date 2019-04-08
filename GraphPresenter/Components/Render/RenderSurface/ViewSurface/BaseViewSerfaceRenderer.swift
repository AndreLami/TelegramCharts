//
//  BaseViewsManager.swift
//  GraphPresenter
//
//  Created by Andre on 3/23/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

class BaseViewSerfaceRenderer : IViewSurfaceRenderer {
    
    func layout(context: ViewSurfaceLayoutContext) {
        self.layout(viewPort: context.viewPort, dimensionsConverter: context.dimensionsConverter)
    }
    
    
    private (set) var container: UIView?
    
    var zIndex: Int = 0
    
    func attachToContainer(_ container: UIView) {
        self.container = container
        self.onAttached()
     }
    
    func detachFromContainer() {
        self.container = nil
        self.onDetached()
    }
    
    func layout(viewPort: ViewPort, dimensionsConverter: DimensionsConverter) {
        
    }
    
    
    // Override methods
    
    func onAttached() {
        
    }
    
    func onDetached() {
        
    }
    
}
