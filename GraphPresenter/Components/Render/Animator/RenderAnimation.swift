//
//  GraphAnimation.swift
//  ChartPresenter
//
//  Created by Andre on 3/11/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

class RenderAnimation: NSObject {
    
    let renderTargetId: String?
    let duration: TimeInterval
    
    let updateBlock: (CGFloat, TimeInterval) -> Void
    let completionBlock: ((Bool) -> Void)?
    
    var easingFunction: IRenderEasing?
    
    private (set) var isFinished = false
    
    var hasElapsed: Bool {
        return self.currentElapsedTime >= self.duration
    }
    
    private var currentElapsedTime: TimeInterval = 0
    
    init(renderTargetId: String?,
         duration: TimeInterval,
         updateBlock: @escaping (CGFloat, TimeInterval) -> Void,
         completion: ((Bool) -> Void)?) {
        
        self.renderTargetId = renderTargetId
        self.duration = duration
        self.updateBlock = updateBlock
        self.completionBlock = completion
    }
    
    func update(elapsedTime: TimeInterval) {
        if self.isFinished {
            return
        }
        
        self.currentElapsedTime += elapsedTime
        let progress = min(1.0, CGFloat(self.currentElapsedTime/self.duration))
        let resultProgress = self.easingFunction?.processProgress(progress) ?? progress
        self.updateBlock(resultProgress, self.currentElapsedTime)
    }
    
    func notifyFinished(finished: Bool) {
        if self.isFinished {
            return
        }
        
        self.isFinished = true
        self.completionBlock?(finished)
    }
    
 
}
