//
//  IRenderEnvironment.swift
//  ChartPresenter
//
//  Created by Andre on 3/12/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

protocol IRenderEnvironment {
    
    var dimensionsConverter: DimensionsConverter { get }
    
    var viewPort: ViewPort { get }
    var targetViewPort: ViewPort { get }
    
    func updateViewPort(_ viewPort: ViewPort)
    
    func createRenderSurface<T>(withParams params: RenderSurfaceParams<T>) -> RendererAttacher<T>
    
    func setNeedsRerender()
    
    @discardableResult
    func animate(duration: TimeInterval,
                 updateBlock: @escaping (CGFloat, TimeInterval) -> Void,
                 complitionBlock: @escaping (Bool) -> Void) -> RenderAnimator.AnimationCancelation
    
    @discardableResult
    func animate(duration: TimeInterval,
                 easing: IRenderEasing,
                 updateBlock: @escaping (CGFloat, TimeInterval) -> Void,
                 complitionBlock: @escaping (Bool) -> Void) -> RenderAnimator.AnimationCancelation
    
    
    func createAnimatableValue<T>(initialValue: T?,
                                  animationStrategy: RenderAnimatableValue<T>.AnimationStrategy,
                                  valueUpdaterBlock: @escaping RenderAnimatableValue<T>.ValueUpdaterBlock<T>) -> RenderAnimatableValue<T>
    
}
