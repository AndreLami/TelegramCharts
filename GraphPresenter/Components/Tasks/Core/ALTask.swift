//
//  ALTask.swift
//
//
//  Created by Andre on 3/10/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation

typealias ALOnTaskComplete = (_ result:Any?, _ error:Error?) -> ()

typealias ALThenBlock = (_ result:Any?) -> ALTask?
typealias ALCatchBlock = (_ error:Error) -> ALTask?

protocol ALTask: ALCancelable {
  
    func onComplete(_ completionBlock: @escaping ALOnTaskComplete)
    
    func then(_ thenBlock: @escaping ALThenBlock) -> ALTask
    func then(_ thenBlock: @escaping ALThenBlockNoResult) -> ALTask
    
    func catchError(_ catchBlock: @escaping ALCatchBlock) -> ALTask
    
    var isComplete: Bool {get}
}


typealias ALThenBlockNoResult = (_ result:Any?) -> ()
typealias ALCatchBlockNoResult = (_ error:Any?) -> ()

extension ALTask {
  
    func then(_ thenBlock: @escaping  ALThenBlockNoResult) -> ALTask {
        return self.then({ (result) -> ALTask? in
            thenBlock(result)
            return nil
        })
    }
    
    func thenTask(_ task: ALTask) -> ALTask {
        return self.then { (result) -> ALTask? in
            return task
        }
    }
    
    
    func catchError(_ catchBlock: @escaping ALCatchBlockNoResult) -> ALTask {
        return self.catchError({ (error) -> ALTask? in
            catchBlock(error)
            return nil
        })
    }
}


