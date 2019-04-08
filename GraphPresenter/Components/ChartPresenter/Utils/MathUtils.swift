//
//  MathUtils.swift
//  ChartPresenter
//
//  Created by Andre on 3/20/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation

class MathUtils {
    
    static func solveLinear(p1: ChartData.ChartCoordinate, p2: ChartData.ChartCoordinate, x: XAxisType) -> YAxisType {
        
        let k = (p2.y - p1.y) / (p2.x - p1.x)
        let b = p1.y - k * p1.x
        
        let y = k * x + b
        
        return y
        
    }
    
}
