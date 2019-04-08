//
//  TelegramChartOriginalData.swift
//  ChartPresenter
//
//  Created by Andre on 3/19/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation

typealias StatisticXType = Int64
typealias StatisticYType = Int64

typealias StatisticPointData = (x: StatisticXType, y: StatisticYType)

extension ChartData.Point {
    
    var statisticPointData: StatisticPointData {
        return self.originalData as! StatisticPointData
    }
}
