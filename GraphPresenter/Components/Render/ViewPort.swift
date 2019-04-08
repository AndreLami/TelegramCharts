//
//  ViewPort.swift
//  ChartPresenter
//
//  Created by Andre on 3/21/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

typealias XAxisType = CGFloat
typealias YAxisType = CGFloat

extension YAxisType {
    
    static var maxVal: YAxisType {
        return CGFloat.greatestFiniteMagnitude
    }
    
    static var minVal: YAxisType {
        return CGFloat.leastNormalMagnitude
    }
    
}

@objc class ViewPort: NSObject {
    
    class Update {
        
        var x: XAxisType?
        var y: YAxisType?
        
        var xEnd: XAxisType?
        var yEnd: XAxisType?
        
        func update(x: XAxisType?) -> Update {
            self.x = x
            
            return self
        }
        
        func update(xEnd: XAxisType?) -> Update {
            self.xEnd = xEnd
            
            return self
        }
        
        func update(y: YAxisType?) -> Update {
            self.y = y
            
            return self
        }
        
        func update(yEnd: YAxisType?) -> Update {
            self.yEnd = yEnd
            
            return self
        }
        
    }
    
    @objc let x: XAxisType
    @objc let y: YAxisType
    
    @objc let xEnd: XAxisType
    @objc let yEnd: XAxisType
    
    var width: XAxisType {
        return self.xEnd - self.x
    }
    
    var height: YAxisType {
        return self.yEnd - self.y
    }
    
    init(x: XAxisType, y: YAxisType, xEnd: XAxisType, yEnd: YAxisType) {
        self.x = min(x, xEnd)
        self.y = min(y, yEnd)
        self.xEnd = max(x, xEnd)
        self.yEnd = max(y, yEnd)
    }
    
    static func update() -> Update {
        return Update()
    }
    
    func update() -> Update {
        return ViewPort.update().update(x: self.x).update(y: self.y).update(xEnd: self.xEnd).update(yEnd: self.yEnd)
    }
    
}
