//
//  IRenderController.swift
//  ChartPresenter
//
//  Created by Andre on 3/12/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation

protocol IRenderController: class {
    
    func attachToRenderEnvironment(_ renderEnvironment: IRenderEnvironment)
    func cleanup()
    
    func onViewPortTransition(fromViewPort from: ViewPort, toViewPort: ViewPort)
    func onViewPortUpdated(_ viewPort: ViewPort)
    
}

