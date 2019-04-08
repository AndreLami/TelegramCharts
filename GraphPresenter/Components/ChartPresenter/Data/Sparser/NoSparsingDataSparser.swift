//
//  NoSparsingDataSparser.swift
//  ChartPresenter
//
//  Created by Andre on 3/19/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation

class NoSparsingDataSparser: IChartDataSparser {
    
    func sparsedData(forChartData chartData: ChartData, segmentSize: XAxisType) -> ALTask {
        return ALReadyTask.init(withResult: chartData)
    }
    
 
    
}
