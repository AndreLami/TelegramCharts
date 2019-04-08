//
//  Heap.swift
//  ChartPresenter
//
//  Created by Andre on 3/18/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation

// Classical heap implementation
final class HeapCollection<T> {
    
    private var slots = [T]()
    
    private var comparator: (T, T) -> Bool
    
    
    public init(withComparator comparator: @escaping (T, T) -> Bool) {
        self.comparator = comparator
    }
    
    public var isEmpty: Bool {
        return self.slots.isEmpty
    }
    
    public var count: Int {
        return self.slots.count
    }
    
    public func push(_ value: T) {
        self.slots.append(value)
        self.restoreHeapUp(self.slots.count - 1)
    }
    
    @discardableResult
    public func pop() -> T? {
        if self.slots.isEmpty {
            return nil
            
        }
        
        if self.slots.count == 1 {
            return self.slots.removeLast()
        } else {
            let value = self.slots.first!
            self.slots[0] = self.slots.removeLast()
            self.restoreHeapDown(from: 0, until: self.slots.count)
            
            return value
        }
    }
    
}

private extension HeapCollection {

    func restoreHeapUp(_ index: Int) {
        var childIndex = index
        let child = self.slots[childIndex]
        var parentIndex = self.findParentIndex(forIndex: childIndex)
        
        while childIndex > 0 && self.comparator(child, self.slots[parentIndex]) {
            self.slots[childIndex] = self.slots[parentIndex]
            childIndex = parentIndex
            parentIndex = self.findParentIndex(forIndex: childIndex)
        }
        
        self.slots[childIndex] = child
    }
    
    func restoreHeapDown(from index: Int, until endIndex: Int) {
        let leftChildIndex = self.findLeftChildIndex(forIndex: index)
        let rightChildIndex = self.findRightChildIndex(forIndex: index)

        var first = index
        if leftChildIndex < endIndex && self.comparator(self.slots[leftChildIndex], self.slots[first]) {
            first = leftChildIndex
        }
        
        if rightChildIndex < endIndex && self.comparator(self.slots[rightChildIndex], self.slots[first]) {
            first = rightChildIndex
        }
        
        if first == index { return }
        
        self.slots.swapAt(index, first)
        self.restoreHeapDown(from: first, until: endIndex)
    }
    
    func findParentIndex(forIndex i: Int) -> Int {
        return (i - 1) / 2
    }
    
    func findLeftChildIndex(forIndex i: Int) -> Int {
        return 2 * i + 1
    }
    
    func findRightChildIndex(forIndex i: Int) -> Int {
        return 2 * i + 2
    }

}
