//
//  ViewRenderSurface.swift
//  GraphPresenter
//
//  Created by Andre on 3/28/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

class ViewRenderSurface: RenderSurface<IViewSurfaceRenderer> {
    
    private var internalView: BaseView!
    private let internalIdentifier: String
    
    private var renderers = [IViewSurfaceRenderer]()
    
    private  let layoutContextMakerBlock: () -> ViewSurfaceLayoutContext
    
    override var identifier: String {
        return internalIdentifier
    }
    
    override var view: UIView {
        return internalView
    }
    
    init(withIdentifier identifier: String, layoutContextMakerBlock: @escaping () -> ViewSurfaceLayoutContext) {
        self.internalIdentifier = identifier
        self.layoutContextMakerBlock = layoutContextMakerBlock
        
        super.init()
        self.setup()
    }
    
    
    
    override func invalidate() {
        self.internalView.setNeedsLayout()
    }
    
    override func addRenderer(_ renderer: IViewSurfaceRenderer) {
        var index = 0
        for candidate in self.renderers {
            if candidate.zIndex >= renderer.zIndex {
                break
            }
            
            index += 1
        }
        
        
        self.renderers.insert(renderer, at: index)
        renderer.attachToContainer(self.view)
        
    }
    
    override func removeRenderer(_ renderer: IViewSurfaceRenderer) {
        self.renderers = self.renderers.filter { (candidate) -> Bool in
            return candidate !== renderer
        }
        
        renderer.detachFromContainer()
    }
    
}

private extension ViewRenderSurface {
    
    func setup() {
        self.internalView = BaseView()
        self.internalView.backgroundColor = UIColor.clear
        self.internalView.layout = ViewLayoutUtils.createLayout { [weak self] (view) in
            self?.doLayout(view: view)
        }
    }
    
    func doLayout(view: UIView) {
        
        let context = self.layoutContextMakerBlock()
        
        for renderer in renderers {
            renderer.layout(context: context)            
        }
    }
    
}
