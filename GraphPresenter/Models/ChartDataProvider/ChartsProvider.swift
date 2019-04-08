//
//  ChartsProvider.swift
//  ChartPresenter
//
//  Created by Andre on 3/19/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation

class ChartsDataProvider: IChartsDataProvider {
    
    
    var dataInvalidatedBlock: (() -> Void)?
    
    private var statistic: Statistic
    private var sparser: IChartDataSparser
    private var internalEnabledChartIds = Set<String>()
    
    init(withStatistic statistic: Statistic, dataSparser sparser: IChartDataSparser = NoSparsingDataSparser()) {
        self.statistic = statistic
        self.sparser = sparser
        
        self.setup()
    }

    func provideChartsData(forViewPort viewPort: ViewPort) -> ALTask {
        
        let availableCharts = self.availableCharts
        if availableCharts.isEmpty {
            return ALReadyTask.init(withResult: [ChartData]())
        }
        
        let segmentSize = viewPort.width
        var allSparsedCharts = [ChartData]()
        
        var currentTask: ALTask? = nil
        for chart in availableCharts {
            let sparseTask = self.sparser.sparsedData(forChartData: chart, segmentSize: segmentSize).then { (result) -> ALTask? in
                let sparsedData = result as! ChartData
                allSparsedCharts.append(sparsedData)
                return nil
            }
            
            if currentTask == nil {
                currentTask = sparseTask
            } else {
                currentTask = currentTask!.then { (result) -> ALTask? in
                    return sparseTask
                }
            }
        }
        
        return currentTask!.then { _ -> ALTask? in
            var result = [ChartData]()
            
            for sparsedChart in allSparsedCharts {
                let cutChart = self.cutOutData(forChartData: sparsedChart, andViewPort: viewPort)
                result.append(cutChart)
            }
            
            return ALReadyTask.init(withResult: result)
        }
        
    }
    
    var allCharts: [ChartData] {
        return self.statistic.charts
    }
    
    var enabledCharts: [ChartData] {
        return self.statistic.charts.filter { (chart) -> Bool in
            self.internalEnabledChartIds.contains(chart.id)
        }
    }
    
    var availableCharts: [ChartData] {
        return self.enabledCharts
    }
    
    var minAllX: XAxisType {
        let allCharts = self.allCharts
        if allCharts.isEmpty {
            return 0
        }
        
        var min = XAxisType.maxVal
        for chart in allCharts {
            if chart.minX < min {
                min = chart.minX
            }
        }
        
        return min
    }
    
    var maxAllX: XAxisType {
        let allCharts = self.allCharts
        if allCharts.isEmpty {
            return 0
        }
        
        var max = XAxisType.minVal
        for chart in allCharts {
            if chart.maxX > max {
                max = chart.maxX
            }
        }
        
        return max
    }
    
    var maxX: XAxisType {
        return self.maxAllX
    }
    
    var minX: XAxisType {
        return self.minAllX
    }
}

extension ChartsDataProvider {
    
    func isChartEnabled(withId chartId: String) -> Bool {
        return self.internalEnabledChartIds.contains(chartId)
    }
    
    func toggleEnableChart(withId chartId: String) {
        if self.isChartEnabled(withId: chartId) {
            self.disableChart(withId: chartId)
        } else {
            self.enableChart(withId: chartId)
        }
    }
    
    func enableChart(withId chartId: String) {
        if !self.internalEnabledChartIds.contains(chartId) {
            self.internalEnabledChartIds.insert(chartId)
            self.onProvidedDataUpdated()
        }
        
    }
    
    func disableChart(withId chartId: String) {
        if self.internalEnabledChartIds.contains(chartId) {
            self.internalEnabledChartIds.remove(chartId)
            self.onProvidedDataUpdated()
        }
    }
    
    func isAllChartHidden() -> Bool {
        return self.internalEnabledChartIds.count == 0
    }
    
}

private extension ChartsDataProvider {
    
    func setup() {
        self.statistic.charts.forEach { (chart) in
            self.enableChart(withId: chart.id)
        }
    }
    
}

private extension ChartsDataProvider {
    
    func cutOutData(forChartData chart: ChartData, andViewPort viewPort: ViewPort) -> ChartData {
        let comparator = { (val: XAxisType, point: ChartData.ChartPoint) -> Int in
            if val < point.coordinate.x {
                return -1
            } else if val > point.coordinate.x {
                return 1
            }
            
            return 0
        }
        
        var leftIndex = CollectionUtils.binarySearchInsertIndex(inArray: chart.points, value: viewPort.x, comparator: comparator)
        var rightIndex = CollectionUtils.binarySearchInsertIndex(inArray: chart.points, value: viewPort.xEnd, comparator: comparator)
        
        // Left index will poinit to first index greater then view port x.
        // Thats why we should move to one index back if possible
        leftIndex = leftIndex > 0 ? leftIndex - 1 : 0
      
        if rightIndex == -1 || rightIndex >= chart.points.count {
            rightIndex = chart.points.count - 1
        }
        
        let points = chart.points[leftIndex ... rightIndex]
        return chart.duplicate(withPoints: Array(points))
    }
    
}

private extension ChartsDataProvider {
    
    func onProvidedDataUpdated() {
        self.dataInvalidatedBlock?()
    }
    
}
