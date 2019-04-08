//
//  CollectionUtils.swift
//  ChartPresenter
//
//  Created by Andre on 3/18/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation


extension Array where Array.Element: Comparable {
    
    func binarySearchInsertIndex(value: Array.Element) -> Int {
        var lowerBound = 0
        var upperBound = self.count - 1
        while lowerBound <= upperBound {
            let midIndex = (lowerBound + upperBound)/2
            let candidate = self[midIndex]
            if candidate < value {
                lowerBound = midIndex + 1
            } else if candidate > value {
                upperBound = midIndex - 1
            } else {
                return midIndex
            }
        }
        
        return lowerBound
    }
    
}

class CollectionUtils {
    
    /**
     * @description comparator returns -1 if first is less then second, 0 in case of equality,
     *              1 in case of first is greater
     **/
    static func binarySearchInsertIndex<T, Y>(inArray array: [T], value: Y, comparator: (Y, T) -> Int) -> Int {
        var lowerBound = 0
        var upperBound = array.count - 1
        while lowerBound <= upperBound {
            let midIndex = (lowerBound + upperBound)/2
            let candidate = array[midIndex]
            let result = comparator(value, candidate)
            if result == 1 {
                lowerBound = midIndex + 1
            } else if result == -1 {
                upperBound = midIndex - 1
            } else {
                return midIndex
            }
        }
        
        return lowerBound
    }
    
}
