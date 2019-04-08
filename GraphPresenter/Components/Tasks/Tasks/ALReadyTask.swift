//
//  ALReadyTask.swift
//
//
//  Created by Andre on 3/10/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation

class ALReadyTask: ALTask {
    
    fileprivate var result: Any?
    fileprivate var error: Error?
    
    init(withResult result:Any) {
        self.result = result
        self.error = nil
    }
    
    init(withError error:Error) {
        self.result = nil
        self.error = error
    }
    
    
    func cancel() {
        
    }
    
    func onCancelled(_ cancelledBlock: @escaping ALOnCancelledBlock) {
        
    }
    
    var isCancelled: Bool {
        get { return false }
    }
    
    
    func onComplete(_ completionBlock: @escaping ALOnTaskComplete) {
        completionBlock(self.result, self.error)
    }
    
     var isComplete: Bool {
        get { return true }
    }

    
    func then(_ thenBlock: @escaping ALThenBlock) -> ALTask {
        let task = ALBlockOperation.performOperation { (promise) in
            promise.resolve(withResult: self.result, andError: self.error)
        }
        
        return task.then(thenBlock)
    }
    
    func catchError(_ catchBlock: @escaping ALCatchBlock) -> ALTask {
        let task = ALBlockOperation.performOperation { (promise) in
            promise.resolve(withResult: self.result, andError: self.error)
        }
        
        return task.catchError(catchBlock)
    }
    
   
    
    
}
