//
//  ObjectsPool.swift
//  GraphPresenter
//
//  Created by Andre on 3/21/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation

class ObjectsPool<T> {
    
    private var internalPool = Array<T>()
    private var size: Int
    
    
    init(withSize size: Int) {
        self.size = size <= 0 ? 1 : size
    }
    
    func getObject() -> T? {
        if self.internalPool.isEmpty {
            return nil
        }
        
        return self.internalPool.removeFirst()
    }
    
    func putOpbject(object: T) {
        if self.internalPool.count < self.size {
            self.internalPool.append(object)
        }
    }
    
}
