//
//  LayoutView.swift
//  ChartPresenter
//
//  Created by Andre on 3/10/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

protocol IViewLayoutListener: class {
    
    func onViewWillLayout(view: UIView)
    func onViewDidLayout(view: UIView)
    
}

class DelegatingViewLayoutListener: IViewLayoutListener {
    
    private weak var delegate: IViewLayoutListener?
    
    init(delegate: IViewLayoutListener) {
        self.delegate = delegate
    }
    
    func onViewDidLayout(view: UIView) {
        self.delegate?.onViewDidLayout(view: view)
    }
    
    func onViewWillLayout(view: UIView) {
        self.delegate?.onViewWillLayout(view: view)
    }
    
    
}


class BaseView: UIView {
    
    var layoutListener: IViewLayoutListener? = nil
    
    
    var layout: IViewLayout? = nil {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    var renderer: IViewRenderer? = nil {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func layoutSubviews() {
        
        self.layoutListener?.onViewWillLayout(view: self)
        
        super.layoutSubviews()
        
        self.layout?.layoutView(view: self)
        
        self.layoutListener?.onViewDidLayout(view: self)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        self.renderer?.draw(context: context, view: self, rect: rect)
    }
    
}
