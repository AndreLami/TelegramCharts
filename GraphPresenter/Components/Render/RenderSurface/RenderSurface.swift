//
//  IRenderSurface.swift
//  GraphPresenter
//
//  Created by Andre on 3/28/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

class RenderSurface<RendererType>: NSObject {
    
    var identifier: String {
        fatalError()
    }
    
    var view: UIView {
        fatalError()
    }
    
    func invalidate() {
        fatalError()
    }
    
    func addRenderer(_ renderer: RendererType) {
        fatalError()
    }
    
    func removeRenderer(_ renderer: RendererType) {
        fatalError()
    }
    
}
