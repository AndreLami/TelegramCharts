//
//  EmptyViewController.swift
//  GraphPresenter
//
//  Created by Yuri Rudenya on 3/21/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

private let TransitionAnimationDuration: TimeInterval = 0.3

class EmptyViewController: BaseGraphController {
    
    fileprivate class EmptyDisplayItem {
        
        var containerView: UIView? = nil
        var label: UILabel? = nil
        
        init() {
            
        }
    }
    
    private var displayItemsManager = EmptyViewManager()
    private var viewItem: EmptyDisplayItem?
    
    func updateForGraphData(_ data: [GraphData]?) {
        if data == nil || data?.count == 0 {
            self.createItemIfNeeded()
            self.displayItemsManager.updateDisplayItem(item: self.viewItem)
        } else {
            self.displayItemsManager.updateDisplayItem(item: nil)
        }
    }
    
    override func onReady() {
        self.renderEnvironment?.addViewsManager(self.displayItemsManager)
    }

    
    
    private class EmptyViewManager: ViewsManager {
        
        private var container: UIView?
        private var item: EmptyViewController.EmptyDisplayItem?
        
        func updateDisplayItem(item: EmptyViewController.EmptyDisplayItem?) {
            
            if item != nil {
                
                self.item?.containerView?.removeFromSuperview()
                self.container?.addSubview(item!.containerView!)
                self.container?.alpha = 0.0
                self.item = item
                
                UIView.animate(withDuration: TransitionAnimationDuration, delay: 0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                    self.container?.alpha = 1.0
                }) { (_) in
                    
                }
                
            } else {
                if self.item != nil {
                    UIView.animate(withDuration: TransitionAnimationDuration, delay: 0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                        self.container?.alpha = 0.0
                    }) { (_) in
                        self.item = nil
                    }
                }
            }
        }
        
        func attachToContainer(_ container: UIView) {
            self.container = container
            self.container?.clipsToBounds = true
        }
        
        func detachFromContainer() {
            
        }
        
        func layout(viewPort: ViewPort, dimensionsConverter: DimensionsConverter) {
            
            guard let item = self.item, let containerBounds = self.container?.bounds else {
                return
            }
            
            let offset: CGFloat = 10.0
            
            item.containerView?.frame = containerBounds
            item.label?.frame = CGRect.init(x: offset, y: offset, width: containerBounds.width - offset * 2, height: containerBounds.height - offset * 2)
            
        }
        
    }
}

private extension EmptyViewController {
    
    func createItemIfNeeded() {
        
        if self.viewItem == nil {

            let displayItem = EmptyDisplayItem.init()

            let containerView = UIView.init()
            containerView.backgroundColor = .white

            let label = UILabel.init()
            label.textAlignment = .center
            label.numberOfLines = 0
            label.text = "NO DATA"

            containerView.addSubview(label)
            
            displayItem.label = label
            displayItem.containerView = containerView

            self.viewItem = displayItem
        }
    }
}
