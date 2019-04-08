//
//  IMetalrenderer.swift
//  GraphPresenter
//
//  Created by Andre on 3/26/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import MetalKit

@objc protocol IMetalRenderer: class {

    func render(withMetalContext context: MetalContext)
    func setupWithView(_ view: MTKView)

}
