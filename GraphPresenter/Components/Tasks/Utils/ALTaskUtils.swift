//
//  ALTaskUtils.swift
//
//
//  Created by Andre on 3/10/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation

class ALTaskUtils {
    
    static func delayedTask(_ delay: TimeInterval) -> ALTask {
        return ALBlockOperation.performOperation(withBlock: { (promise) in
            let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                promise.fulfill(withResult: true)
            }
        })
    }
    
    static func onNextRunloop() -> ALTask {
        return ALBlockOperation.performOperation(withBlock: { (promise) in
            DispatchQueue.main.async {
                promise.fulfill(withResult: true)
            }
        })
    }
    
    static func createFuture() -> ALTask & ALPromise {
        let operation = ALBlockOperation.init { (promise) in}
        _ = operation.perform()
        
        return operation
    }
    
}

extension ALTask {
    
    func independentTask() -> ALTask {
        
        let independentTask = ALBlockOperation.performOperation { (promise) in
            self.onComplete({ (result, error) in
                promise.resolve(withResult: result, andError: error)
            })
        }
        
        self.onCancelled {
            independentTask.cancel()
        }
        
        return independentTask
    }
    
    func onDone(_ doneBlock: @escaping ()->()) {
        self.onComplete { (result, error) in
            doneBlock()
        }
        
        self.onCancelled {
            doneBlock()
        }
    }
    
}
