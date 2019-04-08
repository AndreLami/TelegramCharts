//
//  CGRenderSurface.swift
//  GraphPresenter
//
//  Created by Andre on 3/28/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

class CGRenderSurface: RenderSurface<ICGSurfaceRenderer> {
    
    private var internalView: BaseView!
    private let internalIdentifier: String
    
    private var renderers = [ICGSurfaceRenderer]()
    
    private let renderContextMakerBlock: (CGContext) -> RenderingContext
    
    override var identifier: String {
        return internalIdentifier
    }
    
    override var view: UIView {
        return internalView
    }
    
    init(withIdentifier identifier: String, andRenderingContextMakerBlock renderContextMakerBlock: @escaping (CGContext) -> RenderingContext) {
        self.internalIdentifier = identifier
        self.renderContextMakerBlock = renderContextMakerBlock
        super.init()
        self.setup()
    }
    
    
    
    override func invalidate() {
        self.internalView.setNeedsDisplay()
    }
    
    override func addRenderer(_ renderer: ICGSurfaceRenderer) {
        var index = 0
        for candidate in self.renderers {
            if candidate.zIndex >= renderer.zIndex {
                break
            }
            
            index += 1
        }
        
        
        self.renderers.insert(renderer, at: index)
    }
    
    override func removeRenderer(_ renderer: ICGSurfaceRenderer) {
        self.renderers = self.renderers.filter { (candidate) -> Bool in
            return candidate !== renderer
        }
    }
    
}

private extension CGRenderSurface {
    
    func setup() {
        self.internalView = BaseView()
        self.internalView.backgroundColor = UIColor.clear
        self.internalView.renderer = ViewRendererUtils.createRenderer { [weak self] (context, view, rect) in
            self?.doRender(drawingContext: context, view: view, rect: rect)
        }
    }
    
    func doRender(drawingContext: CGContext, view: UIView, rect: CGRect) {
        let renderContext =  self.renderContextMakerBlock(drawingContext)
        
        drawingContext.clear(rect)
        
        for renderer in renderers {
            renderer.render(withContext: renderContext)
        }
    }
    
}
