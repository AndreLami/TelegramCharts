//
//  GraphDataProvider.swift
//  ChartPresenter
//
//  Created by Andre on 3/10/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit



protocol IChartsDataProvider {
    
    func provideChartsData(forViewPort: ViewPort) -> ALTask
    
    var availableCharts: [ChartData] { get }
    var allCharts: [ChartData] { get }
    
    var maxX: XAxisType { get }
    var minX: XAxisType { get }
    
    var dataInvalidatedBlock: (() -> Void)? { get set }
    
}


