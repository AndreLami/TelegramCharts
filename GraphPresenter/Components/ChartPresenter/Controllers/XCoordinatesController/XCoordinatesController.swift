//
//  XCoordinatesController.swift
//  ChartPresenter
//
//  Created by Andre on 3/12/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

private let TransitionAnimationDuration: TimeInterval = 0.3

final class XCoordinatesController: BaseGraphController {
    
    fileprivate class LabelDisplayItem: Hashable {
        
        func hash(into hasher: inout Hasher) {
            return ObjectIdentifier(self).hash(into: &hasher)
        }
        
        static func == (left: LabelDisplayItem, right: LabelDisplayItem) -> Bool {
            return left === right
        }
        
        var hashValue: Int {
            return ObjectIdentifier(self).hashValue
        }
        
        var identifier: Int
        
        var text: String?
        
        var level: XAxisType
        
        var view: UILabel!
        
        init(identifier: Int, level: XAxisType) {
            self.identifier = identifier
            self.level = level
        }
    }
    
    private class DisplayLabelsCollections {
        
        var itemsMap = [Int : LabelDisplayItem]()
        
    }
    
    private var displayItemsManager: XCoordinatesViewsManager!
    
    private var currentSplitStep: XAxisType?
    private var splitAreaSize: XAxisType?
    
    private var minFittedSplitStep = 4
    private var maxFittedSplitStep = 6
    
    private var prevSplitViewPort: ViewPort?
    
    private var labelItems = DisplayLabelsCollections()
    
    private var labelsPool = ObjectsPool<UILabel>(withSize: 10)
    
    override func onViewPortUpdated(_ viewPort: ViewPort) {
        self.transitionToViewPort(viewPort)
    }
    
    override func onReady() {
        self.displayItemsManager = XCoordinatesViewsManager.init(withLabelsPool: self.labelsPool)
        
        let itemsSurfaceParams = ViewSurfaceParams.init(identifier: "ItemsSurface")
        let attacher = self.renderEnvironment?.createRenderSurface(withParams: itemsSurfaceParams)
        attacher?.addRenderer(self.displayItemsManager)
        
        
        self.transitionToViewPort(self.renderEnvironment!.viewPort)
    }
    
    override func applyDisplayParams(_ oldDisplayParams: ChartDisplayParams?, newDisplayParams: ChartDisplayParams, animated: Bool) {
        let displayItems = labelItems.itemsMap.values
        
        let applyBlock = {
            for item in displayItems {
                item.view.textColor = newDisplayParams.primaryTextColor
            }
        }
        
        if animated {
            UIView.animate(withDuration: ChartDisplayModeAnimationDuration, delay: 0, options: .beginFromCurrentState, animations: {
                applyBlock()
            }, completion: nil)
        }
        
    }
    
}

// X cooridnates handling
private extension XCoordinatesController {
    
    private func transitionToViewPort(_ viewPort: ViewPort) {
        // 1. Resolve split step
        // 2. Make levels
        // 3. Diff with current
        // 4. Reduce diff
        
        let splitStep: XAxisType = self.resolveSplitStep(forViewPort: viewPort, forCurrentSplitStep: self.currentSplitStep)
        
        self.currentSplitStep = splitStep
        
        var labelItemsToRemove = [LabelDisplayItem]()
        var labelItemsToAdd = [LabelDisplayItem]()
        
        let splitSteps = self.splitViewPortSpace(forViewPort: viewPort, withSplitStep: splitStep)
        var itemsToRemoveKeys = Set<Int>(self.labelItems.itemsMap.keys)
        
        for splitStep in splitSteps {
            
            let identifier = Int(splitStep)
            
            if self.labelItems.itemsMap[identifier] != nil {
                itemsToRemoveKeys.remove(identifier)
            } else {
                
                let item = self.createLabelItem(withIdentifier: identifier, andLevel: splitStep, inViewPort: viewPort)
                labelItemsToAdd.append(item)
            }
        }
        
        for itemToRemoveKey in itemsToRemoveKeys {
            let item = self.labelItems.itemsMap[itemToRemoveKey]!
            self.labelItems.itemsMap.removeValue(forKey: itemToRemoveKey)
            
            labelItemsToRemove.append(item)
        }
        
        for itemToAdd in labelItemsToAdd {
            self.labelItems.itemsMap[itemToAdd.identifier] = itemToAdd
        }
        
        self.displayItemsManager.updateDisplayItems(addItems: labelItemsToAdd, removeItems: labelItemsToRemove)
    }

    
    func createLabelItem(withIdentifier identifier: Int, andLevel level: XAxisType, inViewPort viewPort: ViewPort) -> LabelDisplayItem {
        let displayItem = LabelDisplayItem.init(identifier: identifier, level: level)
        
        var view = labelsPool.getObject()
        if view == nil {
            view = UILabel()
            view!.font = UIFont.systemFont(ofSize: 12)
        }
        
        view!.text = self.graphParams.xCoordinateLabler?.makeLabel(forCoordinate: level, inViewPort: viewPort)
        view!.textColor = self.currentDisplayParams.primaryTextColor
        view!.sizeToFit()
        
        displayItem.view = view
        
        return displayItem
    }
    
    func resolveSplitStep(forViewPort viewPort: ViewPort, forCurrentSplitStep currentSplitStep: XAxisType?) -> XAxisType {
        
        if let currentSplitStep = self.currentSplitStep, let prevViewPort = self.prevSplitViewPort {
            let diff = abs(prevViewPort.width - viewPort.width)
            let scale: XAxisType
            let maxWidth = min(prevViewPort.width, viewPort.width)
            scale = diff / maxWidth
            
            if scale < 0.05 {
                return currentSplitStep
            }
        }

        self.prevSplitViewPort = viewPort
        
        var viewPortWidth = Int(ceil(viewPort.width - viewPort.width * 0.3))
        var splitStep = 1
        var level = 0
        while viewPortWidth > 0 {
            viewPortWidth /= 2
            level += 1
            splitStep *= 2
        }
        
        // Clean last 2 splits
        if level > 2 {
            splitStep /= 4
        }
        
      
        return XAxisType(splitStep)
    }
    
    func splitViewPortSpace(forViewPort viewPort: ViewPort, withSplitStep splitStep: XAxisType) -> [XAxisType] {
        
        let minVPPoint = Int(ceil(viewPort.x))
        let split = Int(splitStep)
        
        let startPoint = (minVPPoint / split) * split
        let endPoint = Int(ceil(viewPort.xEnd))
        
        
        var currentPoint = startPoint
        var splits = [XAxisType]()
        while currentPoint <= endPoint {
            let splitPoint = currentPoint
            splits.append(XAxisType(splitPoint))
            currentPoint += split
        }
        
        return splits
    }
    
    
    
}


private class XCoordinatesViewsManager: BaseViewSerfaceRenderer {
    
    private var displayItems = Set<XCoordinatesController.LabelDisplayItem>()
    private var cleanupItems = Set<XCoordinatesController.LabelDisplayItem>()
    
    
    private var labelsPool: ObjectsPool<UILabel>?
    
    init(withLabelsPool labelsPool: ObjectsPool<UILabel>) {
        self.labelsPool = labelsPool
    }
    
    func updateDisplayItems(addItems: [XCoordinatesController.LabelDisplayItem], removeItems: [XCoordinatesController.LabelDisplayItem]) {
        for addItem in addItems {
            displayItems.insert(addItem)
        }
        
        UIView.animate(withDuration: TransitionAnimationDuration, delay: 0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
            removeItems.forEach { (item) in
                self.cleanupItems.insert(item)
                self.displayItems.remove(item)
                
                item.view?.alpha = 0
            }
        }) { (_) in
            removeItems.forEach { (item) in
                self.labelsPool?.putOpbject(object: item.view)
                item.view.removeFromSuperview()
                self.cleanupItems.remove(item)
            }
        }
        
        addItems.forEach { (item) in
            item.view!.alpha = 0.0
            container?.addSubview(item.view!)
        }
        
        UIView.animate(withDuration: TransitionAnimationDuration, delay: 0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
            addItems.forEach { (item) in
                item.view!.alpha = 1.0
            }
        }) { (_) in }
    }
    
    override func onAttached() {
        self.container?.clipsToBounds = true
    }
    
    override func layout(viewPort: ViewPort, dimensionsConverter: DimensionsConverter) {
        
        let yOffset: CGFloat = 5
        
        self.displayItems.forEach { (item) in
            
            let displayPoint = dimensionsConverter.convertGraphPointToDisplayPoint(viewPort: viewPort, graphPoint: GraphData.GraphCoordinate.init(x: item.level, y: 0))
            
            let centerX = displayPoint.x - item.view!.bounds.width/2
            let centerY = displayPoint.y + item.view!.bounds.height/2 + yOffset
            
            item.view!.center = CGPoint.init(x: centerX, y: centerY)
        }
        
        self.cleanupItems.forEach { (item) in
            let displayPoint = dimensionsConverter.convertGraphPointToDisplayPoint(viewPort: viewPort, graphPoint: GraphData.GraphCoordinate.init(x: item.level, y: 0))
            
            let centerX = displayPoint.x - item.view!.bounds.width/2
            let centerY = displayPoint.y + item.view!.bounds.height/2 + yOffset
            
            item.view!.center = CGPoint.init(x: centerX, y: centerY)
        }
    }
    
}
