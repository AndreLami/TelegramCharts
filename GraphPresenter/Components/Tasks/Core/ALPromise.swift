//
//  TaskPromise.swift
//
//
//  Created by Andre on 3/10/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation

protocol ALPromise {
    func fulfill(withResult result:Any)
    func fulfill(withTask task:ALTask)
    
    func reject(withError error:Error)
    
    func resolve(withResult result:Any?, andError error:Error?)
    
    var isResolved: Bool { get }
}
