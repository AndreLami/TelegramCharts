//
//  ALBlockOperation.swift
//
//
//  Created by Andre on 3/10/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation


typealias ALOperationTaskBlock = (_ promise:ALPromise) -> ()
typealias ALOperationThenBlock = (_ result:Any?, _ promise:ALPromise) -> ()

class ALBlockOperation {
    fileprivate var result: Any?;
    fileprivate var error: Error?;
    
    fileprivate var started = false;
    fileprivate var canceled = false;
    fileprivate var fulfilled = false;
    
    fileprivate var taskBlock: ALOperationThenBlock?
    fileprivate var cancellationToken: ALCancellationToken?
    
    fileprivate var completionListeners = [ALOnTaskComplete]()
    fileprivate var cancelListeners = [ALOnCancelledBlock]()
    
    static func performOperation(withBlock block: @escaping ALOperationTaskBlock) -> ALTask {
        let operation = ALBlockOperation.init(withCancellationToken:nil, andTaskBlock: block)
        return operation.perform()!
    }
    
    convenience init(withTaskBlock taskBlock: @escaping ALOperationTaskBlock) {
        self.init(withCancellationToken:nil, andTaskBlock:taskBlock)
    }
    
    fileprivate convenience init(withCancellationToken token:ALCancellationToken?, andTaskBlock taskBlock: @escaping ALOperationTaskBlock) {
        let thenBlock: ALOperationThenBlock = { (result:Any?, promise:ALPromise) -> () in
            taskBlock(promise)
        }
        
        self.init(withCancellationToken:nil, andThenBlock:thenBlock)
    }
    
    fileprivate init(withCancellationToken token: ALCancellationToken?, andThenBlock thenBlock: @escaping ALOperationThenBlock) {
        self.taskBlock = thenBlock
        self.cancellationToken = token
        
        if self.cancellationToken == nil {
            self.cancellationToken = ALCancellationToken()
        }
        
        self.cancellationToken!.onCancelled {[weak self] in
            self?.performCancellation()
        }
    }
    
    
    func perform() -> ALTask? {
        return self.perform(withResult: nil)
    }
    
    fileprivate func perform(withResult result:Any?) -> ALTask {
        assert(self.started == false, "Already started")
        
        self.started = true
        self.taskBlock!(result, self)
        
        return self
    }
    
    var isFulfilled: Bool {
        get { return self.fulfilled }
    }
}

extension ALBlockOperation: ALTask {
    func cancel() {
        self.cancellationToken?.cancel()
    }
    
    func onCancelled(_ cancelledBlock: @escaping ALOnCancelledBlock) {
        if (!self.isCancelled) {
            self.cancelListeners.append(cancelledBlock)
        } else {
            cancelledBlock()
        }
    }
    
    var isCancelled: Bool {
        get { return self.canceled }
    }
    
    fileprivate func performCancellation() {
        if self.canceled || self.fulfilled {
            return;
        }
        
        self.canceled = true
        
        for cancellationListener in self.cancelListeners {
            cancellationListener()
        }
        
        self.cancelListeners.removeAll()
        self.completionListeners.removeAll()
        self.taskBlock = nil
    }
    
    
    
    var isComplete: Bool {
        get { return self.result != nil || self.error != nil}
    }
    
    func onComplete(_ copletionBlock: @escaping ALOnTaskComplete) {
        if !self.isCancelled {
            if self.isResolved {
                copletionBlock(self.result, self.error);
            } else {
                self.completionListeners.append(copletionBlock)
            }
        }
    }
    
    func then(_ thenBlock: @escaping ALThenBlock) -> ALTask {
        
        let operation = ALBlockOperation.init(withCancellationToken: self.cancellationToken) { (result, promise) in
            let task = thenBlock(result)
            if task != nil {
                promise.fulfill(withTask: task!)
            } else {
                promise.fulfill(withResult: result!)
            }
        }
        
        self.onComplete { (result, error) in
            if error == nil {
                _ = operation.perform(withResult: result!)
            } else {
                _ = operation.reject(withError: error!)
            }
        }
        
        return operation;
    }
    
    func catchError(_ catchBlock: @escaping ALCatchBlock) -> ALTask {
        let operation = ALBlockOperation.init(withCancellationToken: self.cancellationToken) { (inError, promise) in
            let error = inError as! Error
            let task = catchBlock(error)
            if task != nil {
                promise.fulfill(withTask: task!)
            } else {
                promise.reject(withError: error)
            }
        }
        
        self.onComplete { (result, error) in
            if error == nil {
                operation.fulfill(withResult: result!)
            } else {
                _ = operation.perform(withResult: error!)
            }
        }
        
        return operation;
    }
}

extension ALBlockOperation: ALPromise {
    
    func fulfill(withResult result:Any) {
        self.resolve(withResult: result, andError: nil)
    }
    
    func fulfill(withTask task:ALTask) {
        self.onCancelled {
            task.cancel()
        }
        
        task.onCancelled {
            self.cancel()
        }
        
        task.onComplete { (result, error) in
            self.resolve(withResult: result, andError: error)
        }
    }
    
    func reject(withError error:Error) {
        self.resolve(withResult: nil, andError: error)
    }
    
    func resolve(withResult result:Any?, andError error:Error?) {
        if self.canceled || self.fulfilled {
            return;
        }
        
        self.fulfilled = true;
        
        self.result = result;
        self.error = error;
        
        for completionListener in self.completionListeners {
            completionListener(self.result, self.error)
        }
        
        self.completionListeners.removeAll()
        self.cancelListeners.removeAll()
        self.taskBlock = nil
    }
    
    var isResolved: Bool {
        get { return self.fulfilled }
    }
}



internal class ALCancellationToken: ALCancelable {
    
    fileprivate(set) var isCancelled: Bool = false
    
    fileprivate var cancelationHandlers = [ALOnCancelledBlock]()
    
    func onCancelled(_ cancelledBlock: @escaping ALOnCancelledBlock) {
        if !self.isCancelled {
            self.cancelationHandlers.append(cancelledBlock)
        } else {
            cancelledBlock()
        }
    }
    
    func cancel() {
        if !self.isCancelled {
            self.isCancelled = true
            self.cancelationHandlers.forEach{ (handler) in
                handler()
            }
            
            self.cancelationHandlers.removeAll()
        }
    }
}
