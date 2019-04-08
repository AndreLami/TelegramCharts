//
//  IChartDataSparser.swift
//  ChartPresenter
//
//  Created by Andre on 3/19/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation

protocol IChartDataSparser: class {
    
    func sparsedData(forChartData: ChartData, segmentSize: XAxisType) -> ALTask
    
}
