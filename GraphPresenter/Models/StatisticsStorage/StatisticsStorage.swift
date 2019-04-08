//
//  StatisticsStorage.swift
//  ChartPresenter
//
//  Created by Andre on 3/19/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation


class StatisticsStorage {
    
    lazy var availableStatistics: ALTask = {

        let executionTask = ALBlockOperation.performOperation { (promise) in
            DispatchQueue.global(qos: .userInitiated).async {
                
                var stats = try? StatisticJsonParser.fromBundlePath("chart_data.json")
                
                stats = stats ?? []
                
                DispatchQueue.main.async {
                    promise.fulfill(withResult: stats!)
                }
            }
        }
        
        return executionTask
    }()
}
