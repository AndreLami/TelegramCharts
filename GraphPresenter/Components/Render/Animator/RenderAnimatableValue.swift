//
//  RenderAnimatableValue.swift
//  ChartPresenter
//
//  Created by Andre on 3/14/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

class RenderAnimatableValue<T> {
    
    typealias ValueUpdaterBlock<T> = (T?, T?, CGFloat) -> T?
    
    enum AnimationStrategy {
        case StartNew
        case Enqueue
        case DropPendingAndEnqueue
    }
    
    private (set) var currentValue: T?
    private (set) var targetValue: T?
    
    let animationStrategy: AnimationStrategy
    let renderTargetId: String?
    let runAnimationBlock: (RenderAnimation) -> RenderAnimator.AnimationCancelation
    let valueUpdaterBlock: ValueUpdaterBlock<T>
    
    var easingFunction: IRenderEasing?
    
    
    var onValueUpdatedBlock: ((T?) -> Void)?
    
    
    var defaultAnimationDuration: TimeInterval = 0.3
    
    private var pendingAnimations = [AnimationData<T>]()
    
    private var runningAnimationCancelation: RenderAnimator.AnimationCancelation? = nil
    
    init(withRenderTargetId renderTargetId: String?,
         animationStrategy: AnimationStrategy,
         runAnimationBlock: @escaping (RenderAnimation) -> RenderAnimator.AnimationCancelation,
         andValueUpdaterBlock valueUpdaterBlock: @escaping (T?, T?, CGFloat) -> T?) {
        
        self.animationStrategy = animationStrategy
        self.renderTargetId = renderTargetId
        self.runAnimationBlock = runAnimationBlock
        self.valueUpdaterBlock = valueUpdaterBlock
    }
    
    
    
    func updateValue(newValue: T?) {
        self.updateValue(newValue: newValue, animated: false, duration: nil)
    }
    
    func updateValueAnimated(newValue: T?, duration: TimeInterval? = nil) {
        self.updateValue(newValue: newValue, animated: true, duration: duration)
    }
    
    func updateValue(newValue: T?, animated: Bool, duration: TimeInterval? = nil) {
       
        
        self.targetValue = newValue
        
        if animated == false {
            self.pendingAnimations.removeAll()
            self.cancelRunningAnimation()
            
            
            self.updateCurrentValue(newVal: newValue)
        } else {
            let animationDuration = duration ?? self.defaultAnimationDuration
            let animationData = AnimationData.init(withTargetValue: newValue, andDuration: animationDuration)
            
            if isAnimationRunning == false {
                self.animate(animationData)
            }
            
            // 1. If StartNew
            
            if case .StartNew = self.animationStrategy {
                // 1. Cancel
                // 2. Start new
                self.cancelRunningAnimation()
                
                self.animate(animationData)
            } else if case .Enqueue = self.animationStrategy {
                // 1. Some animation is running, so enqueu animation block
                
                self.pendingAnimations.append(animationData)
            } else if case .DropPendingAndEnqueue = self.animationStrategy {
                // 1. Some animation is running, so clean pending and enqueu animation block
                
                self.pendingAnimations.removeAll()
                self.pendingAnimations.append(animationData)
            }
            
        }
    }
    
    private func animate(_ animationData: AnimationData<T>) {
        self.cancelRunningAnimation()
        
        let oldValue = self.currentValue
        let targetValue = animationData.targetValue
    
        let updateBlock = { [weak self] (percent: CGFloat, elapsed: TimeInterval) -> Void in
            let newVal = self?.valueUpdaterBlock(oldValue, targetValue, percent)
            
            self?.updateCurrentValue(newVal: newVal)
        }
        
        let completionBlock = { [weak self] (finished: Bool) in
            if finished {
                self?.handledAnimationFinished()
            }
        }
        
        let animation = RenderAnimation.init(renderTargetId: self.renderTargetId,
                                             duration: animationData.duration,
                                             updateBlock: updateBlock,
                                             completion: completionBlock)
        
        animation.easingFunction = self.easingFunction
        
        self.runningAnimationCancelation = self.runAnimationBlock(animation)
    }
    
    private func handledAnimationFinished() {
        self.runningAnimationCancelation = nil
        
        if self.pendingAnimations.count > 0 {
            let pendingAnimation = self.pendingAnimations.removeFirst()
            self.animate(pendingAnimation)
        }
    }
    
    private func cancelRunningAnimation() {
        self.runningAnimationCancelation?.cancel()
        self.runningAnimationCancelation = nil
    }
    
    private var isAnimationRunning: Bool {
        return self.runningAnimationCancelation != nil
    }
    
    private class AnimationData<T> {
        let targetValue: T?
        let duration: TimeInterval
        
        
        init(withTargetValue targetValue: T?, andDuration duration: TimeInterval) {
            self.targetValue = targetValue
            self.duration = duration
        }
    }
    
    private func updateCurrentValue(newVal: T?) {
        self.currentValue = newVal
        self.onValueUpdatedBlock?(newVal)
    }
    
}


