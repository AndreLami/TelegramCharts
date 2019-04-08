//
//  CGSurfaceRenderer.swift
//  GraphPresenter
//
//  Created by Andre on 3/28/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation

protocol ICGSurfaceRenderer: class {
    
    var zIndex: Int { get set }
    
    func render(withContext context: RenderingContext)
}
