//
//  GraphAnimator.swift
//  ChartPresenter
//
//  Created by Andre on 3/11/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

class RenderAnimator {
    
    class AnimationCancelation {
        
        private let cancellationBlock: () -> Void
        private var cancelled: Bool = false
        
        init(withCancellationBlock cancellationBlock: @escaping () -> Void) {
            self.cancellationBlock = cancellationBlock
        }
        
        func cancel() {
            if self.cancelled {
                return
            }
            
            self.cancelled = true
            self.cancellationBlock()
        }
    }
    
    private var runningAnimations = Set<RenderAnimation>()
    
    private let displayLink: InternalDisplayLink
    var invalidationBlock: (([String]?) -> Void)?
    
    private var started = false
    
    init() {
        self.displayLink = InternalDisplayLink()
        self.setup()
    }
    
    func runAnimation(_ animation: RenderAnimation) -> AnimationCancelation {
        self.runningAnimations.insert(animation)
        self.startLinkIfNeeded()
        
        return AnimationCancelation { [weak self] in
            self?.finishAnimations([animation], finished: false)
        }
    }
    
}

private extension RenderAnimator {
    
    func setup() {
        self.displayLink.handleTickBlock = { [weak self] interval in
            self?.handleTick(timeElapsed: interval)
        }
    }
    
    
    func startLinkIfNeeded() {
        if self.started {
            return
        }
        
        self.startLink()
    }
    
    func startLink() {
        self.started = true
        self.displayLink.start()
    }
    
    func stopLinkIfNeeded() {
        if !self.started {
            return
        }
        
        if self.runningAnimations.count > 0 {
            return
        }
        
        self.stopLink()
    }
    
    func stopLink() {
        self.started = true
        self.displayLink.start()
    }
    
    
    
}


private extension RenderAnimator {
    
    func handleTick(timeElapsed: TimeInterval) {
        var targetIds = Set<String>()
        var invalidateAllTargets = false
        var finishedAnimations = [RenderAnimation]()
        
        for animation in self.runningAnimations {
            if animation.renderTargetId == nil {
                invalidateAllTargets = true
            } else {
                targetIds.insert(animation.renderTargetId!)
            }
            
            animation.update(elapsedTime: timeElapsed)
            
            if animation.hasElapsed {
                finishedAnimations.append(animation)
            }
        }
        
        self.finishAnimations(finishedAnimations, finished: true)
        self.invalidationBlock?(invalidateAllTargets ? nil : Array(targetIds))
    }
    
    func finishAnimations(_ animations: [RenderAnimation], finished: Bool) {
        for animation in animations {
            if self.runningAnimations.contains(animation) {
                self.runningAnimations.remove(animation)
                
                animation.notifyFinished(finished: finished)
            }
        }
        
        self.stopLinkIfNeeded()
    }
    
   
    
}

private class InternalDisplayLink {
    
    class DisplayLinkHolder {
        
        var tickBlock: ((CADisplayLink) -> Void)?
        
        @objc func handleTick(displayLink: CADisplayLink) {
            self.tickBlock?(displayLink)
        }
        
    }
    
    var displayLink: CADisplayLink?
    var displayLinkHolder: DisplayLinkHolder
    
    let piggybackPeriod = 1.0/55.0
    let skipPeriod = 1.0/70.0
    
    var handleTickBlock: ((TimeInterval) -> Void)?
    
    init() {
        self.displayLinkHolder = DisplayLinkHolder()
        
        self.displayLinkHolder.tickBlock = {[weak self] displayLink -> Void in
            self?.handleTick(displayLink: displayLink)
        }
        
    }
    
    deinit {
        if self.displayLink != nil {
            self.displayLink!.remove(from: RunLoop.main, forMode: RunLoop.Mode.common)
        }
    }
    
    fileprivate var started = false
    fileprivate var lastTickDate: Date?
    
    func start() {
        if self.started == false{
            self.started = true
            self.lastTickDate = Date()
            
            if self.displayLink == nil {
                self.displayLink = CADisplayLink.init(target: self.displayLinkHolder, selector: #selector(DisplayLinkHolder.handleTick(displayLink:)))
                
                self.displayLink!.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
            }
            
            self.displayLink?.isPaused = false
        }
    }
    
    func stop() {
        if self.started == true {
            self.started = false
            self.lastTickDate = nil
            self.displayLink?.isPaused = true
        }
    }
    
    private func handleTick(displayLink: CADisplayLink) {
        if !self.started {
            return
        }
        
        let currentDate = Date()
        let tickTime = currentDate.timeIntervalSince(self.lastTickDate!)
        if tickTime < self.skipPeriod {
            return
        }
        
        self.handleTickBlock?(tickTime)
        
        self.lastTickDate = currentDate
    }
    
    
}
