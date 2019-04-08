//
//  RenderStage.swift
//
//  Created by Andre on 3/11/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit
import MetalKit



private class InternalTransitionViewPort {
    
    var onUpdatedBlock: ((ViewPort) -> Void)?
    
    let x: RenderAnimatableValue<XAxisType>
    let y: RenderAnimatableValue<XAxisType>
    
    let xEnd: RenderAnimatableValue<XAxisType>
    let yEnd: RenderAnimatableValue<XAxisType>
    
    init(x: RenderAnimatableValue<XAxisType>,
         y: RenderAnimatableValue<YAxisType>,
         xEnd: RenderAnimatableValue<XAxisType>,
         yEnd: RenderAnimatableValue<YAxisType>) {
        self.x = x
        self.y = y
        self.xEnd = xEnd
        self.yEnd = yEnd
        
        let props = [self.x, self.y, self.xEnd, self.yEnd]
        for prop in props {
            prop.onValueUpdatedBlock = { [weak self] _ in
                self?.notifyUpdted()
            }
        }
    }
    
    var currentViewPort: ViewPort {
        return ViewPort.init(x: self.x.currentValue!,
                             y: self.y.currentValue!,
                             xEnd: self.xEnd.currentValue!,
                             yEnd: self.yEnd.currentValue!)
    }
    
    var targetViewPort: ViewPort {
        return ViewPort.init(x: self.x.targetValue!,
                             y: self.y.targetValue!,
                             xEnd: self.xEnd.targetValue!,
                             yEnd: self.yEnd.targetValue!)
    }
    
    private func notifyUpdted() {
        self.onUpdatedBlock?(self.currentViewPort)
    }
    
}



private class RenderSurfaceWrapper: RenderSurface<Any> {
    
    let wrapped: Any
    
    private let internalIdentifier: String
    override var identifier: String {
        return self.internalIdentifier
    }
    
    private let internalView: UIView
    override var view: UIView {
        return internalView
    }
    
    private let invalidateBlock: () -> Void
    override func invalidate() {
        self.invalidateBlock()
    }
    
    init<T>(surface: RenderSurface<T>) {
        self.internalIdentifier = surface.identifier
        self.internalView = surface.view
        self.invalidateBlock = {
            surface.invalidate()
        }
        
        self.wrapped = surface
    }
}

private class RenderTarget {
    
    var params: RenderTargetParams!
    
    var renderSurfaces = [RenderSurfaceWrapper]()
    
    var identifier: String {
        return params.identifier
    }
    
    static func create(params: RenderTargetParams) -> RenderTarget {
        let target = RenderTarget()
        target.params = params
        
        return target
    }
    
    func addRenderSurface<T>(_ renderSurface: RenderSurface<T>) {
        self.renderSurfaces.append(RenderSurfaceWrapper.init(surface: renderSurface))
    }
    
    func removeRenderSurface<T>(_ renderSurface: RenderSurface<T>) {
        self.renderSurfaces = self.renderSurfaces.filter { (candidate) -> Bool in
            return candidate.identifier != renderSurface.identifier
        }
    }
    
    func findRenderSurface(identifier: String) -> Any? {
        let surface = self.renderSurfaces.first { (candidate) -> Bool in
            return candidate.identifier == identifier
        }
        
        return surface?.wrapped
    }
    
    func invalidate() {
        self.renderSurfaces.forEach { (surface) in
            surface.invalidate()
        }
    }
    
}

private typealias RenderControllerToTargetBinding = (controller: IRenderController, target: RenderTarget)

private func makeRenderControllerBinding(controller: IRenderController, target: RenderTarget) -> RenderControllerToTargetBinding {
    return (controller: controller, target: target)
}


class RenderStage: NSObject {
    
    var currentViewPort: ViewPort {
        return self.transitionalViewPort.currentViewPort
    }
    
    var targetViewPort: ViewPort {
        return self.transitionalViewPort.targetViewPort
    }
    
    var renderOffset: UIEdgeInsets {
        get {
            return self.dimensionsConverter.offset
        }
        set {
            self.dimensionsConverter.offset = newValue
        }
    }
    
    private var transitionalViewPort: InternalTransitionViewPort!
    
    private (set) var mainView: UIView!
    
    private var renderTargtes = [RenderTarget]()
    private var renderTargtesMap = [String: RenderTarget]()
    
    private var renderControllers = [IRenderController]()
    private var renderTargetIdToRenderControllersMap = [String : [IRenderController]]()
    private var renderControlleroRenderTargetBindings = [RenderControllerToTargetBinding]()
    
    private (set) var dimensionsConverter: DimensionsConverter!
    private (set) var animator: RenderAnimator!
    
    init(viewPort: ViewPort) {
        super.init()
        self.setup(viewPort: viewPort)
    }
    
    private var surfaceManagers = [String: Any]()
    
}

class RendererAttacher<T> {
    
    private let renderSurface: RenderSurface<T>
    init(renderSurface: RenderSurface<T>) {
        self.renderSurface = renderSurface
    }
    
    func addRenderer(_ renderer: T) {
        self.renderSurface.addRenderer(renderer)
    }
    
    func removeRenderer(_ renderer: T) {
        self.renderSurface.removeRenderer(renderer)
    }
    
}



extension RenderStage {
    
    func addRendererController(_ renderController: IRenderController, forRenderTargetwithParams params: RenderTargetParams) {
        
        if self.hasRenderController(renderController) {
            return
        }
        
        let renderTarget = self.requestRenderTarget(withParams: params)
        
        
        self.registerRenderController(renderController, forRenderTarget: renderTarget)
    }
    
    
    func removeRendererController(_ controller: IRenderController) {
        if !self.hasRenderController(controller) {
            return
        }
        
        self.unregisterRenderController(controller)
    }
    
    
    func updateViewPort(_ viewPortUpdate: ViewPort.Update, animated: Bool = false) {
        
        
        if viewPortUpdate.x != nil {
            self.transitionalViewPort!.x.updateValue(newValue: viewPortUpdate.x!, animated: animated)
        }
        
        if viewPortUpdate.y != nil {
            self.transitionalViewPort!.y.updateValue(newValue: viewPortUpdate.y!, animated: animated)
        }
        
        if viewPortUpdate.xEnd != nil {
            self.transitionalViewPort!.xEnd.updateValue(newValue: viewPortUpdate.xEnd!, animated: animated)
        }
        
        if viewPortUpdate.yEnd != nil {
            self.transitionalViewPort!.yEnd.updateValue(newValue: viewPortUpdate.yEnd!, animated: animated)
        }
        
        
        let currentViewPort = self.currentViewPort
        let targetViewPort = self.targetViewPort
        
        self.renderTargtes.forEach { (target) in
            target.invalidate()
        }
        
        self.renderControllers.forEach { (controller) in
            controller.onViewPortTransition(fromViewPort: currentViewPort, toViewPort: targetViewPort)
        }
        
        self.invalidateDisplay()
    }
    
    func updateViewPort(_ viewPort: ViewPort, animated: Bool = false) {
        self.updateViewPort(viewPort.update(), animated: animated)

    }
    
    func setNeedsRerender() {
        self.invalidateDisplay()
    }
    
}

extension RenderStage {
    
    func addInteraction(interraction: UIGestureRecognizer) {
        self.mainView.addGestureRecognizer(interraction)
    }
    
    func removeInteration(interraction: UIGestureRecognizer) {
        self.mainView.removeGestureRecognizer(interraction)
    }
    
    func convert(displayPoint: CGPoint) -> GraphData.GraphCoordinate {
        return self.dimensionsConverter.convertDisplayPointToGraphPoint(viewPort: self.currentViewPort, displayPoint: displayPoint)
    }
    
    func convert(graphPoint: GraphData.GraphCoordinate) -> CGPoint {
        return self.dimensionsConverter.convertGraphPointToDisplayPoint(viewPort: self.currentViewPort, graphPoint: graphPoint)
    }
    
}

fileprivate extension RenderStage {
    
    func registerSurfaceManager<T>(surfaceManager: RenderSurfaceManager<T>) {
        let descriptor = RenderSurfaceDescriptor<T>()
        self.surfaceManagers[descriptor.describe] = surfaceManager
        surfaceManager.onAttachedToStage(stage: self)
    }
    
    func createRenderSurface<T>(targetId: String, withParams params: RenderSurfaceParams<T>) -> RendererAttacher<T> {
        guard let renderTarget = self.renderTargtesMap[targetId] else {
            fatalError("Error! No render target (\(targetId)) for surface with id: \(params.identifier)")
        }
        
        if let surface = renderTarget.findRenderSurface(identifier: params.identifier) as? RenderSurface<T> {
            return RendererAttacher.init(renderSurface: surface)
        }
        
        let manager = self.surfaceManagers[params.descriptor.describe] as! RenderSurfaceManager<T>
        let surface = manager.createRenderSurface(withParams: params)
        
        renderTarget.addRenderSurface(surface)
        let surfaceView = surface.view
        surfaceView.layer.zPosition = CGFloat(params.zIndex)
        
        self.mainView.addSubview(surfaceView)
        
        return RendererAttacher.init(renderSurface: surface)
    }
    
}

private extension RenderStage {
    
    func requestRenderTarget(withParams params: RenderTargetParams) -> RenderTarget {
        let identifier = params.identifier
        var renderTarget = self.renderTargtesMap[identifier]
        if renderTarget != nil {
            return renderTarget!
        }
        
        renderTarget = self.createRenderTarget(params: params)
        self.registerRenderTarget(renderTarget: renderTarget!)
        
        return renderTarget!
    }
    
    
    func dropRenderTarget(withId targetId: String) {
        if let renderTarget = self.renderTargtesMap[targetId] {
            self.dropRenderTarget(renderTarget)
        }
    }
    
    func dropRenderTarget(_ renderTarget: RenderTarget) {
        let targetId = renderTarget.identifier
        
        renderTarget.renderSurfaces.forEach { (renderSurface) in
            renderSurface.view.removeFromSuperview()
        }
        
        self.renderTargtesMap.removeValue(forKey: targetId)
        self.renderTargtes = self.renderTargtes.filter { (candidate) -> Bool in
            return candidate.identifier != renderTarget.identifier
        }
    }
    
}

private extension RenderStage {
    
    func registerRenderController(_ renderController: IRenderController, forRenderTarget renderTarget: RenderTarget) {
        let environment = self.createRenderEnvironment(forRenderController: renderController, andRenderTarget: renderTarget)
        self.renderControllers.append(renderController)
        
        var controllers = self.renderTargetIdToRenderControllersMap[renderTarget.identifier]
        if controllers == nil {
            controllers = [IRenderController]()
        }
        
        controllers?.append(renderController)
        let binding = makeRenderControllerBinding(controller: renderController, target: renderTarget)
        self.renderControlleroRenderTargetBindings.append(binding)
        self.renderTargetIdToRenderControllersMap[renderTarget.identifier] = controllers
        
        renderController.attachToRenderEnvironment(environment)
    }
    
    func unregisterRenderController(_ renderController: IRenderController) {
        self.renderControllers = self.renderControllers.filter { (candidate) -> Bool in
            candidate !== renderController
        }
        
        let bindingIndex = self.renderControlleroRenderTargetBindings.firstIndex { (binding) -> Bool in
            binding.controller === renderController
        }
        
        if bindingIndex != nil {
            let binding = self.renderControlleroRenderTargetBindings[bindingIndex!]
            let targetId = binding.target.identifier
            
            var controllers = self.renderTargetIdToRenderControllersMap[targetId]
            if controllers != nil {
                controllers = controllers!.filter { (candidate) -> Bool in
                    candidate !== renderController
                }
                
                self.renderTargetIdToRenderControllersMap[targetId] = controllers
                if controllers!.isEmpty {
                    self.dropRenderTarget(withId: targetId)
                }
            }
            
            self.renderControlleroRenderTargetBindings.remove(at: bindingIndex!)
        }
        
     
        renderController.cleanup()
    }
    
    func createRenderEnvironment(forRenderController renderController: IRenderController, andRenderTarget target: RenderTarget) -> IRenderEnvironment {
        return InternalRenderEnvironment.init(renderStage: self, renderController: renderController, renderTarget: target)
    }
    
}


private extension RenderStage {
    
    func setup(viewPort: ViewPort) {
        self.setupViews(viewPort: viewPort)
        self.setupData(viewPort: viewPort)
    }
    
    func setupViews(viewPort: ViewPort) {
        
        let mainView = BaseView()
        self.mainView = mainView
        
        mainView.layout = ViewLayoutUtils.createLayout { (view) in
            for subview in view.subviews {
                subview.frame = view.bounds
            }
        }
    }
    
    func setupData(viewPort: ViewPort) {
        
        self.registerSurfaceManager(surfaceManager: ViewSurfaceManager.init())
        self.registerSurfaceManager(surfaceManager: CGSurfaceManager.init())
        self.registerSurfaceManager(surfaceManager: MetalSurfaceManager.init())
        
        self.animator = RenderAnimator()
        self.animator.invalidationBlock = { [weak self] targetIds in
            guard let `self` = self else {
                return
            }
            
            // All targets
            if targetIds == nil {
                self.invalidateDisplay()
            } else {
                targetIds!.forEach { (targetId) in
                    self.invalidateRenderTarget(withId: targetId)
                }
            }
            
        }
        
        self.dimensionsConverter = DimensionsConverter(view: self.mainView)
        
        let transitionalX = self.createXTransitionViewPortValue(initiaValue: viewPort.x)
        let transitionalY = self.createXTransitionViewPortValue(initiaValue: viewPort.y)
        
        let transitionalXEnd = self.createXTransitionViewPortValue(initiaValue: viewPort.xEnd)
        let transitionalYEnd = self.createXTransitionViewPortValue(initiaValue: viewPort.yEnd)
        
        self.transitionalViewPort = InternalTransitionViewPort.init(x: transitionalX,
                                                                    y: transitionalY,
                                                                    xEnd: transitionalXEnd,
                                                                    yEnd: transitionalYEnd)
        
        
        self.transitionalViewPort.onUpdatedBlock = { [weak self] viewPort in
            self?.onViewPortUpdated(viewPort: viewPort)
        }
    }
    
    func createXTransitionViewPortValue(initiaValue: XAxisType) -> RenderAnimatableValue<XAxisType> {
        let value = RenderAnimatableValue<XAxisType>.init(withRenderTargetId: nil,
                                   animationStrategy: .StartNew,
                                   runAnimationBlock: { [weak self] (animation) -> RenderAnimator.AnimationCancelation in
           return self!.animator.runAnimation(animation)
        }) { (from, to, percent) -> XAxisType in
            from! + (to! - from!) * XAxisType(percent)
        }
        
        value.updateValue(newValue: initiaValue)
        value.easingFunction = RenderEasingUtils.quadraticEaseOut
        
        return value
    }
    
    func createYTransitionViewPortValue(initiaValue: YAxisType) -> RenderAnimatableValue<YAxisType> {
        let value = RenderAnimatableValue<YAxisType>.init(withRenderTargetId: nil,
                                                          animationStrategy: .StartNew,
                                                          runAnimationBlock: { [weak self] (animation) -> RenderAnimator.AnimationCancelation in
                                                            return self!.animator.runAnimation(animation)
        }) { (from, to, percent) -> YAxisType in
            from! + (to! - from!) * YAxisType(percent)
        }
        
        value.easingFunction = RenderEasingUtils.quadraticEaseOut
        value.updateValue(newValue: initiaValue)
        
        return value
    }
    
}

private extension RenderStage {
    
    func createRenderTarget(params: RenderTargetParams) -> RenderTarget {
        let renderTargetView = RenderTarget.create(params: params)
        
        
        return renderTargetView
    }
    
    func registerRenderTarget(renderTarget: RenderTarget) {
        self.renderTargtes.append(renderTarget)
        self.renderTargtesMap[renderTarget.params.identifier] = renderTarget
        
    }

}

private extension RenderStage {

    func hasRenderController(_ controller: IRenderController) -> Bool {
        let result = self.renderControllers.filter { (candidate) -> Bool in
            candidate === controller
        }.first
        
        return result != nil
    }

}

private extension RenderStage {
    
    func onViewPortUpdated(viewPort: ViewPort) {
        self.renderControllers.forEach { (controller) in
            controller.onViewPortUpdated(viewPort)
        }
        
        self.invalidateDisplay()
    }
    
    func invalidateDisplay() {
        self.renderTargtesMap.values.forEach { (target) in
            target.invalidate()
        }
    }
    
    func invalidateRenderTarget(withId targetId: String) {
        let renderTarget = self.renderTargtesMap[targetId]
        renderTarget?.invalidate()
    }
    
}

private class InternalRenderEnvironment {
    
    weak var renderStage: RenderStage?
    weak var renderController: IRenderController?
    weak var renderTarget: RenderTarget?
    
    init(renderStage: RenderStage, renderController: IRenderController, renderTarget: RenderTarget) {
        self.renderStage = renderStage
        self.renderController = renderController
        self.renderTarget = renderTarget
    }
    
}

extension InternalRenderEnvironment: IRenderEnvironment {
  
    func createRenderSurface<T>(withParams params: RenderSurfaceParams<T>) -> RendererAttacher<T> {
        return self.renderStage!.createRenderSurface(targetId: self.renderTarget!.identifier, withParams: params)
    }
    
    func createAnimatableValue<T>(initialValue: T?,
                                  animationStrategy: RenderAnimatableValue<T>.AnimationStrategy,
                                  valueUpdaterBlock: @escaping RenderAnimatableValue<T>.ValueUpdaterBlock<T>)  -> RenderAnimatableValue<T> {
        
        let result = RenderAnimatableValue.init(withRenderTargetId: self.renderTarget!.identifier,
                                                animationStrategy: animationStrategy,
                                                runAnimationBlock:
            { [weak self](animation) -> RenderAnimator.AnimationCancelation in
                
                return self!.renderStage!.animator!.runAnimation(animation)
                                    
            }, andValueUpdaterBlock: valueUpdaterBlock)
        
        result.updateValue(newValue: initialValue)
        return result
    }
   
    
    @discardableResult
    func animate(duration: TimeInterval,
                 updateBlock: @escaping (CGFloat, TimeInterval) -> Void,
                 complitionBlock: @escaping (Bool) -> Void) -> RenderAnimator.AnimationCancelation {
        
        let animation = RenderAnimation.init(renderTargetId: self.renderTarget!.identifier,
                                             duration: duration,
                                             updateBlock: updateBlock,
                                             completion: complitionBlock)
        
        return self.renderStage!.animator.runAnimation(animation)
    }
    
    @discardableResult
    func animate(duration: TimeInterval,
                 easing: IRenderEasing,
                 updateBlock: @escaping (CGFloat, TimeInterval) -> Void,
                 complitionBlock: @escaping (Bool) -> Void) -> RenderAnimator.AnimationCancelation {
        let animation = RenderAnimation.init(renderTargetId: self.renderTarget!.identifier,
                                             duration: duration,
                                             updateBlock: updateBlock,
                                             completion: complitionBlock)
        
        animation.easingFunction = easing
        
        return self.renderStage!.animator.runAnimation(animation)
    }
    
    var viewPort: ViewPort {
        return self.renderStage!.currentViewPort
    }
    
    var targetViewPort: ViewPort {
        return self.renderStage!.targetViewPort
    }
    
    func updateViewPort(_ viewPort: ViewPort) {
        self.renderStage?.updateViewPort(viewPort)
    }
    
    var dimensionsConverter: DimensionsConverter {
        return self.renderStage!.dimensionsConverter
    }
    
    func setNeedsRerender() {
        guard let targetId = self.renderTarget?.identifier else {
            return
        }
        
        self.renderStage?.invalidateRenderTarget(withId: targetId)
    }
   
}
