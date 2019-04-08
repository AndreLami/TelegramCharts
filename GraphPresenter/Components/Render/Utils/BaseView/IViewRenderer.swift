//
//  IViewRendere.swift
//  ChartPresenter
//
//  Created by Andre on 3/10/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

protocol IViewRenderer {
    
    func draw(context: CGContext, view: UIView, rect: CGRect)
    
}

typealias RenderBlock = (CGContext, UIView, CGRect) -> Void

class ViewRendererUtils {
    
    static func createRenderer(withBlock renderBlock: @escaping RenderBlock) -> IViewRenderer {
        return BlockViewRenderer(withBlock: renderBlock)
    }
    
}

class BlockViewRenderer: IViewRenderer {
    
    let renderBlock: RenderBlock
    
    init(withBlock renderBlock: @escaping RenderBlock) {
        self.renderBlock = renderBlock
    }
    
    func draw(context: CGContext, view: UIView, rect: CGRect) {
        self.renderBlock(context, view, rect)
    }
    
}
