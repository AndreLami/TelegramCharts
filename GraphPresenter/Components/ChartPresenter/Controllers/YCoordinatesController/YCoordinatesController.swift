//
//  XCoordinatesConotroller.swift
//  ChartPresenter
//
//  Created by Andre on 3/15/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

private let AppearAnimationDuration: TimeInterval = 0.3
private let DissmisAnimationDuration: TimeInterval = 0.15

final class YCoordinatesController: BaseGraphController {
    
    fileprivate class LabelDisplayItem: Hashable {
        
        static func == (lhs: YCoordinatesController.LabelDisplayItem, rhs: YCoordinatesController.LabelDisplayItem) -> Bool {
            return lhs.identifier == rhs.identifier
        }
        
        var hashValue: Int {
            return self.identifier.hashValue
        }
        
        func hash(into hasher: inout Hasher) {
            return self.identifier.hash(into:&hasher)
        }
        
        var identifier: String
        
        var text: String?
        
        var level: YAxisType
        
        var view: UILabel!
        
        init(identifier: String, level: YAxisType) {
            self.identifier = identifier
            self.level = level
        }
    }
    
    private var labelsPool = ObjectsPool<UILabel>(withSize: 10)
    
    private var displayItemsManager: YCoordinatesViewsManager!
    
    private var levelsSurfaceAttcher: RendererAttacher<ICGSurfaceRenderer>!
    
    private var levelsRenderer: LevelRenderer?
    private var zeroLevelRenderer: LevelRenderer?
    
    private var transitionViewPort: ViewPort? = nil
    
    private var pendingViewPort: ViewPort? = nil
    private var inTransition = false
    
    private var currentLevel: Int? = nil
    private var numberOfRows: Int = 6
    
    private var labelItems: [YCoordinatesController.LabelDisplayItem]?
    
    private var displayModeTransitionAnimationCancalation: RenderAnimator.AnimationCancelation? = nil
    private var animatorsPresentationAnimationCancelation: RenderAnimator.AnimationCancelation? = nil
    
    override init(withParams params: ChartPresenterParams, andDisplayMode mode: String) {
        super.init(withParams: params, andDisplayMode: mode)
        
        self.displayItemsManager = YCoordinatesViewsManager.init(labelsPool: self.labelsPool)
    }
    
    override func onViewPortTransition(fromViewPort from: ViewPort, toViewPort: ViewPort) {
        
        // We are interrested only on y level, and if its diff is negligible, ignore it
        if self.transitionViewPort != nil && abs(self.transitionViewPort!.yEnd - toViewPort.yEnd) < 0.5 {
            return
        }
        
        // If we are in transition, then just remember target view port
        if (self.inTransition) {
            
            self.pendingViewPort = toViewPort
            return
        }
        
        self.transitionToViewPort(toViewPort)
    }
    
    override func onReady() {
        let itemsSurfaceParams = ViewSurfaceParams.init(identifier: "ItemsSurface")
        let itemsSurfaceAttacher = self.renderEnvironment?.createRenderSurface(withParams: itemsSurfaceParams)
        itemsSurfaceAttacher!.addRenderer(self.displayItemsManager!)
        
        let levelsSurfaceParams = CGSurfaceParams.init(identifier: "LevelsSurface")
        self.levelsSurfaceAttcher = self.renderEnvironment?.createRenderSurface(withParams: levelsSurfaceParams)
        
        
        self.zeroLevelRenderer = self.createLevelRenderer(forLevels: [LevelRenderer.Row.init(withLevel: 0)], isMain: true)
        self.zeroLevelRenderer?.rowAlpha = 1.0
        self.levelsSurfaceAttcher.addRenderer(self.zeroLevelRenderer!)
        
        self.transitionToViewPort(self.renderEnvironment!.viewPort)
    }
    
    override func applyDisplayParams(_ oldDisplayParams: ChartDisplayParams?, newDisplayParams: ChartDisplayParams, animated: Bool) {
        guard let displayItems = self.labelItems else {
            return
        }
        
        self.displayModeTransitionAnimationCancalation?.cancel()
        self.displayModeTransitionAnimationCancalation = nil
        
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
        
        let zeroLevelRenderer = self.zeroLevelRenderer
        let levelRenderer = self.levelsRenderer
        
        if animated && oldDisplayParams != nil {
            let fromMainColor = oldDisplayParams!.primaryAxisColor
            let toMainColor = newDisplayParams.primaryAxisColor
            
            let fromSecondaryColor = oldDisplayParams?.secondaryAxisColor ?? UIColor.black
            let toSecondaryolor = newDisplayParams.secondaryAxisColor
            
            
            let cancelation = self.renderEnvironment?.animate(duration: ChartDisplayModeAnimationDuration, updateBlock: { (progress, elapsed) in
                zeroLevelRenderer?.rowColor = UIColor.transition(fromColor: fromMainColor, toColor: toMainColor, progress: progress) ?? toMainColor
                if levelRenderer != nil {
                    levelRenderer!.rowColor = UIColor.transition(fromColor: fromSecondaryColor, toColor: toSecondaryolor, progress: progress) ?? toSecondaryolor
                }
            }, complitionBlock: { _ in })
            
            self.displayModeTransitionAnimationCancalation = cancelation
        } else {
            zeroLevelRenderer?.rowColor = newDisplayParams.primaryAxisColor
            levelRenderer?.rowColor = newDisplayParams.secondaryAxisColor
        }
    }
    
}


private extension YCoordinatesController {
    
    func createLevelRenderer(forLevels levels: [LevelRenderer.Row], isMain: Bool = false) -> LevelRenderer {
        
        let levelsRenderer = LevelRenderer.init()
        
        levelsRenderer.updateLevels(levels)
        levelsRenderer.rowWidth = isMain ? 1.0 : 0.5
        
        levelsRenderer.rowAlpha = 0.0
        levelsRenderer.rowColor = isMain ? self.currentDisplayParams.primaryAxisColor : self.currentDisplayParams.secondaryAxisColor
        
        return levelsRenderer
    }
}

// Cooridnates handling
private extension YCoordinatesController {
    
    func transitionToViewPort(_ viewPort: ViewPort) {
        let levels = self.calculateLevels(forViewPort: viewPort)
        self.transitionYCoordinateLabels(toViewPort: viewPort, withLevels: levels)
        
        self.transitionCoordinateRows(toViewPort: viewPort, withLevels: levels)
    }
    
    func transitionCoordinateRows(toViewPort viewPort: ViewPort, withLevels axesLevels: [YAxisType]) {
        if self.levelsRenderer != nil {
            self.animatorsPresentationAnimationCancelation?.cancel()
            self.animatorsPresentationAnimationCancelation = nil
            
            
            let currentRenderer = self.levelsRenderer!
            let currentAlpha = currentRenderer.rowAlpha ?? 1.0
            
            _ = self.renderEnvironment!.animate(duration: DissmisAnimationDuration, updateBlock: { (progress, elapsed) in
                currentRenderer.rowAlpha = (currentAlpha - progress)
            }) { [weak self] (finished) in
                self?.levelsSurfaceAttcher.removeRenderer(currentRenderer)
            }
        }
      
        var levels = [LevelRenderer.Row]()
        for axisLevel in axesLevels {
            if axisLevel == 0 {
                continue
            }
            
            
            levels.append(LevelRenderer.Row.init(withLevel: axisLevel))
        }
        
        let levelsRenderer = self.createLevelRenderer(forLevels: levels)
        self.levelsRenderer = levelsRenderer
        
        
        self.levelsSurfaceAttcher.addRenderer(levelsRenderer)
        
        self.animatorsPresentationAnimationCancelation = self.renderEnvironment!.animate(duration: AppearAnimationDuration, updateBlock: { (progress, elapsed) in
            levelsRenderer.rowAlpha = 1.0 * progress
        }) { _ in }
    }
    
    func transitionYCoordinateLabels(toViewPort viewPort: ViewPort, withLevels levels: [YAxisType]) {
        let fromViewPort = self.transitionViewPort
        self.labelItems = self.createLabelItems(fromViewPort: fromViewPort, toViewPort: viewPort, forLevels: levels)
        
        self.transitionViewPort = viewPort
        self.inTransition = true

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + AppearAnimationDuration * 2.0/4.0) {  [weak self ] in
            self?.tryNextTransition()
        }
        self.displayItemsManager.updateDisplayItems(self.labelItems!)
    }
    
    func tryNextTransition() {
        self.inTransition = false
        
        if self.pendingViewPort != nil {
            let targetViewPort = self.pendingViewPort
            self.pendingViewPort = nil
            self.transitionToViewPort(targetViewPort!)
        }
    }
    
    
    func createLabelItems(fromViewPort: ViewPort?, toViewPort: ViewPort, forLevels levels: [YAxisType]) -> [LabelDisplayItem] {
        var displayItems = [LabelDisplayItem]()
        for level in levels {
            let displayItem = self.createLabelItem(forLevel: level, viewPort: toViewPort)
            displayItems.append(displayItem)
        }
        
        return displayItems
    }
    
    
    func createLabelItem(forLevel level: YAxisType, viewPort: ViewPort) -> LabelDisplayItem {
        var view = self.labelsPool.getObject()
        if view == nil {
            view = UILabel()
            view!.font = UIFont.systemFont(ofSize: 12)
            
        }
        
        let levelNumber = Int(level)
        let displayItem = LabelDisplayItem.init(identifier: "\(levelNumber)", level: level)
        
        view!.textColor = self.currentDisplayParams.primaryTextColor
        view!.text = self.graphParams.yCoordinateLabler?.makeLabel(forCoordinate: level, inViewPort: viewPort)
        view!.sizeToFit()
        
        
        displayItem.view = view
        
        return displayItem
    }
    
    func calculateLevels(forViewPort viewPort: ViewPort) -> [YAxisType] {
        
        let botY: YAxisType = 0
        let topY = viewPort.yEnd
        
        let step = (topY - botY) / YAxisType(self.numberOfRows)
        
        var levels = [YAxisType]()
        
        for i in 0 ..< self.numberOfRows {
            let level = botY + step * YAxisType(i)
            levels.append(level)
        }
        
        return levels
    }
    
}


private class YCoordinatesViewsManager: BaseViewSerfaceRenderer {
    

    
    private var displayItems = [YCoordinatesController.LabelDisplayItem]()
    private var cleanupItems = Set<YCoordinatesController.LabelDisplayItem>()
    
    private var labelsPool: ObjectsPool<UILabel>
    
    init(labelsPool: ObjectsPool<UILabel>) {
        self.labelsPool = labelsPool
        super.init()
        self.zIndex = 10
    }
    
    func updateDisplayItems(_ displayItems: [YCoordinatesController.LabelDisplayItem]) {
        let oldDisplayItems = self.displayItems
        
        
        
        UIView.animate(withDuration: DissmisAnimationDuration, delay: 0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
            oldDisplayItems.forEach { (item) in
                self.cleanupItems.insert(item)
                item.view?.alpha = 0
            }
        }) { (_) in
            oldDisplayItems.forEach { (item) in
                self.labelsPool.putOpbject(object: item.view!)
                item.view?.removeFromSuperview()
                self.cleanupItems.remove(item)
            }
        }
        
        self.displayItems = displayItems
        
        displayItems.forEach { (item) in
            item.view!.alpha = 0.0
            container?.addSubview(item.view!)
        }
        
        
        UIView.animate(withDuration: AppearAnimationDuration, delay: 0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
            displayItems.forEach { (item) in
                item.view!.alpha = 1.0
            }
        }) { (_) in }
    }
    
    override func onAttached() {
        self.container!.clipsToBounds = true
    }
    
    
    override func layout(viewPort: ViewPort, dimensionsConverter: DimensionsConverter) {
        let xOffset: CGFloat = 0
        let yOffset: CGFloat = 5
        
        
        
        self.displayItems.forEach { (item) in
            
            var displayPoint = dimensionsConverter.convertGraphPointToDisplayPoint(viewPort: viewPort, graphPoint: GraphData.GraphCoordinate.init(x: 0, y: item.level))
            displayPoint.x = xOffset
            let centerX = xOffset + item.view!.bounds.width/2
            let centerY = displayPoint.y - yOffset - item.view!.bounds.height/2
            
            item.view!.center = CGPoint.init(x: centerX, y: centerY)
        }
        
        self.cleanupItems.forEach { (item) in
            var displayPoint = dimensionsConverter.convertGraphPointToDisplayPoint(viewPort: viewPort, graphPoint: GraphData.GraphCoordinate.init(x: 0, y: item.level))
            displayPoint.x = xOffset
            let centerX = xOffset + item.view!.bounds.width/2
            let centerY = displayPoint.y - yOffset - item.view!.bounds.height/2
            
            item.view!.center = CGPoint.init(x: centerX, y: centerY)
        }
    }
    
}
