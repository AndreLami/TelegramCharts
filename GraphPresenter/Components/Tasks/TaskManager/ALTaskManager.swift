//
//  ALTaskManager.swift
//
//
//  Created by Andre on 3/10/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation

class ALTaskManager {
    
    fileprivate var tasksMap = Dictionary<Int, ALTask>()
    fileprivate var taskCounter = 0
    
    deinit {
        self.cleanup()
    }
    
    func when(_ task:ALTask) -> ALTask {
        self.addTask(task)
        return task
    }
    
    func addTask(_ task:ALTask) {
        self.registerTask(task)
    }
    
    func performTask(_ taskBlock: @escaping ALOperationTaskBlock) {
        let task = ALBlockOperation.performOperation(withBlock: taskBlock)
        self.registerTask(task)
    }
    
    fileprivate func registerTask(_ task:ALTask) {
        let taskId = self.generateTaskId()
        self.tasksMap[taskId] = task
        
        task.onComplete {[weak self] (result, error) in
            self?.tasksMap.removeValue(forKey: taskId)
        }
        
        task.onCancelled {[weak self] in
            self?.tasksMap.removeValue(forKey: taskId)
        }
    }
    
    func cleanup() {
        for task in self.tasksMap.values {
            task.cancel()
        }
        
        self.tasksMap.removeAll()
    }
    
    fileprivate func generateTaskId() -> Int {
        let id = self.taskCounter
        self.taskCounter += 1
        if self.taskCounter > 32000 {
            self.taskCounter = 0
        }
        
        return id
    }
}
