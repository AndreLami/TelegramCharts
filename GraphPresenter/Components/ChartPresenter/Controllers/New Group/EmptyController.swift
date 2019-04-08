//
//  EmptyViewController.swift
//  GraphPresenter
//
//  Created by Andre on 3/21/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

final class EmptyController: BaseGraphController {
    
    fileprivate class EmptyDisplayItem {
        
        var containerView: UIView!
        var label: UILabel? = nil
        
        init() {
            
        }
    }
    
    private var displayItemsManager: EmptyViewManager!
    
    func updateForGraphData(_ data: [GraphData]?) {
        if data == nil || data?.isEmpty == true {
            self.displayItemsManager.showEmptyView(show: true)
        } else {
            self.displayItemsManager.showEmptyView(show: false)
        }
    }
    
    override func applyDisplayParams(_ oldDisplayParams: ChartDisplayParams?, newDisplayParams: ChartDisplayParams, animated: Bool) {
        self.displayItemsManager.updateDisplayMode(displayParams: newDisplayParams, animated: animated)
    }
    
    override func onReady() {
        self.displayItemsManager = EmptyViewManager.init(withDisplayParams: self.currentDisplayParams)
        
        let attacher = self.renderEnvironment?.createRenderSurface(withParams: ViewSurfaceParams.init(identifier: "ViewSurface"))
        attacher!.addRenderer(self.displayItemsManager)
    }

    private class EmptyViewManager: BaseViewSerfaceRenderer {
        
        override init() {
            super.init()
            self.zIndex = 100
        }
        
        private var item: EmptyController.EmptyDisplayItem!
        private var displayParams: ChartDisplayParams!
        
        private var isShowing = false
        
        init(withDisplayParams displayParams: ChartDisplayParams) {
            super.init()
            
            self.item = self.createDisplayItem()
            self.applyDisplayParams(displayParams, animated: false)
        }
        
        func updateDisplayMode(displayParams: ChartDisplayParams, animated: Bool) {
            self.applyDisplayParams(displayParams, animated: animated)
        }
        
        func showEmptyView(show: Bool) {
            if self.isShowing == show {
                return
            }
            
            self.isShowing = show
            if show {
                if self.item.containerView.superview == nil {
                    self.container?.addSubview(self.item!.containerView!)
                }
                
                
                self.container?.backgroundColor = .clear
                let item = self.item!
                
                UIView.animate(withDuration: ChartDisplayModeAnimationDuration, delay: 0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                    item.containerView!.alpha = 1.0
                }) { (_) in
                    
                }
            } else {
                UIView.animate(withDuration: ChartDisplayModeAnimationDuration, delay: 0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                    self.item!.containerView!.alpha = 0.0
                }) { (finshed) in
                    if finshed {
                        self.item!.containerView.removeFromSuperview()
                    }
                }
            }
        }
        
        private func applyDisplayParams(_ displayParams: ChartDisplayParams, animated: Bool) {
            self.displayParams = displayParams
            let applyAnimated = self.isShowing && animated
            
            
            if applyAnimated {
                UIView.animate(withDuration: ChartDisplayModeAnimationDuration, delay: 0, options: [.beginFromCurrentState], animations: {
                    self.item.containerView?.backgroundColor = displayParams.primaryBackgroundColor
                    self.item.label?.textColor = displayParams.primaryTextColor
                }) { (_) in
                    
                }
            } else {
                self.item.containerView?.backgroundColor = displayParams.primaryBackgroundColor
                self.item.label?.textColor = displayParams.primaryTextColor
            }
        }
        
        override func onAttached() {
            self.container!.clipsToBounds = true
        }
        
        override func layout(viewPort: ViewPort, dimensionsConverter: DimensionsConverter) {
            
            guard let item = self.item, let containerBounds = self.container?.bounds else {
                return
            }
            
            let offset: CGFloat = 10.0
            
            item.containerView?.frame = containerBounds
            item.label?.frame = CGRect.init(x: offset, y: offset, width: containerBounds.width - offset * 2, height: containerBounds.height - offset * 2)
            
        }
        
        func createDisplayItem() -> EmptyDisplayItem {
            let displayItem = EmptyDisplayItem.init()
            
            let containerView = UIView.init()
            containerView.alpha = 0.0
            
            let label = UILabel.init()
            label.textAlignment = .center
            label.numberOfLines = 0
            label.text = "NO DATA"
            label.backgroundColor = .clear
            
            containerView.addSubview(label)
            
            displayItem.label = label
            displayItem.containerView = containerView
            
            return displayItem
        }
    }
}
