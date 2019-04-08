//
//  DouglasPeukerDataSparser.swift
//  ChartPresenter
//
//  Created by Andre on 3/19/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

private let UseBitmapThresholdPoint = 2000

class DouglasPeukerDataSparser: IChartDataSparser {
    
    
    
    private class ChartDataCache {
        
        let chartId: String
        
        init(chartId: String) {
            self.chartId = chartId
        }
        
        var calculatedLevels: ALTask?
        var sparseDataPerLevelMap: ALTask?
    }
    
    private let levelScale: XAxisType = 2
    private let maxPointsPerLevel: Int
    
    private var chartsCache = [String: ChartDataCache]()
    
    init(maxPointsPerLevel: Int) {
        self.maxPointsPerLevel = maxPointsPerLevel
        
    }
    
    class SparsityLevel {
        
        var levelNumber: Int
        var maxPointsNumber: Int
        var segmentSize: XAxisType
        
        init(withLevelNumber level: Int, maxPointsNumber: Int, segmentSize: XAxisType) {
            self.levelNumber = level
            self.maxPointsNumber = maxPointsNumber
            self.segmentSize = segmentSize
        }
    }
    
    
    
    func sparsedData(forChartData chartData: ChartData, segmentSize: XAxisType) -> ALTask {
        var resolvedLevel: Int? = nil
        
        let levelsDataMapTask = self.fetchSparseDataMap(forChart: chartData)
        
        let levelDataTask = self.whenLevelsReady(chartData: chartData).then { (result) -> ALTask? in
            let levels = result as! [SparsityLevel]
            
            var resultLevel: SparsityLevel? = nil
            for level in levels {
                if level.segmentSize >= segmentSize {
                    resultLevel = level
                    break
                }
            }
            
            if resultLevel == nil {
                resultLevel = levels.last!
            }
            
            
            resolvedLevel = resultLevel!.levelNumber
            return levelsDataMapTask
        }.then { (result) -> ALTask? in
            let levelsDataMap = result as! [Int : GraphData]
            let data = levelsDataMap[resolvedLevel!]!
            data.tag = "\(resolvedLevel!)"
            
            return ALReadyTask.init(withResult: data)
        }
        
        return levelDataTask
    }
    
}

private extension DouglasPeukerDataSparser {
    
    // swift required it to be private in private extension. Weird
    private func cacheData(forChartData chartData: ChartData) -> ChartDataCache {
        var chartCache = self.chartsCache[chartData.id]
        if chartCache == nil {
            chartCache = ChartDataCache.init(chartId: chartData.id)
            self.chartsCache[chartData.id] = chartCache
        }
        
        return chartCache!
    }
    
}
private extension DouglasPeukerDataSparser {
    
    func calculateLevels(chartData: ChartData) -> ALTask {
        return self.resolveScaleLavels(chartData: chartData, withMaxPointsPerLevel: self.maxPointsPerLevel)
    }
    
    func whenLevelsReady(chartData: ChartData) -> ALTask {
        return self.calculateLevels(chartData: chartData)
    }
    
    func resolveScaleLavels(chartData: GraphData, withMaxPointsPerLevel maxPointsPerLevel: Int) -> ALTask {
        let cache = self.cacheData(forChartData: chartData)
        if cache.calculatedLevels == nil {
            cache.calculatedLevels = self.performInBackground {
                let points = chartData.points
                
                let levels: [SparsityLevel]
                if points.count <= maxPointsPerLevel {
                    let level = SparsityLevel.init(withLevelNumber: 1, maxPointsNumber: maxPointsPerLevel, segmentSize: chartData.maxX - chartData.minX)
                    levels = [level]
                } else {
                    levels = self.calculatePreciseSparsityLevels(forData: chartData, withMaxPointsPerLevel: maxPointsPerLevel)
                }
                
                return levels
            }
        }
        
        let calculationTask = cache.calculatedLevels!.independentTask()
        return calculationTask
    }
    
}

// Levels calculation

private extension DouglasPeukerDataSparser {
    
    func calculatePreciseSparsityLevels(forData data: GraphData, withMaxPointsPerLevel maxPointsPerLevel: Int) -> [SparsityLevel] {
        let points = data.points
        let pointsCount = points.count
        if  points.count <= maxPointsPerLevel {
            let level = SparsityLevel.init(withLevelNumber: 1, maxPointsNumber: maxPointsPerLevel, segmentSize: data.maxX - data.minX)
            return [level]
        }
        
        var minSparsity: XAxisType = XAxisType.maxVal
        
        var leftPointIndex = 0
        var rightPointIndex = maxPointsPerLevel - 1
        
        while rightPointIndex < pointsCount {
            let leftX = points[leftPointIndex].coordinate.x
            let rightX = points[rightPointIndex].coordinate.x
            
            let sparsity = rightX - leftX
            
            if sparsity < minSparsity {
                minSparsity = sparsity
            }
            
            leftPointIndex += 1
            rightPointIndex += 1
        }
        
        let totalDistance = data.maxX - data.minX
        
        let minSupportedNumberOfSegments = YAxisType((2 * pointsCount) / maxPointsPerLevel)
        
        let minSegmentSize = totalDistance / minSupportedNumberOfSegments
        let segmentSize = minSparsity
        
        let resultStartSegmentSize: YAxisType
        if segmentSize.isNaN || segmentSize < minSegmentSize {
            resultStartSegmentSize = minSegmentSize
        } else {
            resultStartSegmentSize = segmentSize
        }
        
        
        return self.calculateSparsityLevels(forData: data, startSegmentSize: resultStartSegmentSize, withMaxPointsPerLevel: maxPointsPerLevel)
    }
    
    func calculateSparsityLevels(forData data: GraphData, startSegmentSize: XAxisType, withMaxPointsPerLevel maxPointsPerLevel: Int) -> [SparsityLevel] {
        
        let totalPoints = YAxisType(data.points.count)
        
        var currentVisiblePointsPerLevel = XAxisType(maxPointsPerLevel)
        var currentSegmentSize = startSegmentSize
        var currentLevel = 1
        var currentPointsNumber = data.points.count
        
        var resultLevels = [SparsityLevel]()
        
        let totalDistance = data.maxX - data.minX
        let xAxisScale = YAxisType(self.levelScale)
        
        
        
        while true {
            
            let level = SparsityLevel.init(withLevelNumber: currentLevel, maxPointsNumber: currentPointsNumber, segmentSize: round(currentSegmentSize))
            resultLevels.append(level)
            
            if currentSegmentSize > totalDistance || currentVisiblePointsPerLevel >= totalPoints {
                level.segmentSize = data.maxX - data.minX
                level.maxPointsNumber = maxPointsPerLevel
                break
            }
            
            currentVisiblePointsPerLevel *= xAxisScale
            currentLevel += 1
            currentSegmentSize *= xAxisScale
            currentPointsNumber = Int(YAxisType(currentPointsNumber)/self.levelScale)
            
        }
        
        return resultLevels
        
    }
    
    
    
}



extension DouglasPeukerDataSparser {
    
    private class PointsCollector {
        
        class SparseData {
            let level: Int
            let maxPoints: Int
            var bitmap: [Bool]?
            var points = [GraphData.Point]()
            
            var currentPointsNumber: Int = 0
            
            init(withLevel level: Int, maxPoints: Int, bitmapSize: Int? = nil) {
                self.level = level
                self.maxPoints = maxPoints
                if bitmapSize != nil {
                    self.bitmap = [Bool](repeating: false, count: bitmapSize!)
                }
            }
            
            var isFull: Bool {
                return self.currentPointsNumber >= self.maxPoints
            }
            
            func addPoint(point: GraphData.Point, at index: Int) {
                if self.bitmap == nil {
                    self.points.append(point)
                } else {
                    self.bitmap?[index] = true
                }
                
                self.currentPointsNumber += 1
            }
            
        }
        
        var activeSparseData = [SparseData]()
        
        var finishedSparseData = [SparseData]()
        
        let initialData: GraphData
        
        init(levels: [SparsityLevel], initialData: GraphData) {
            self.initialData = initialData
            let graphDataSize = initialData.points.count
            
            for level in levels {
                let useBitmap = level.maxPointsNumber > UseBitmapThresholdPoint
                let bitmapSize = useBitmap ? graphDataSize : nil
                let sparseData = SparseData.init(withLevel: level.levelNumber, maxPoints: level.maxPointsNumber, bitmapSize: bitmapSize)
                
                self.activeSparseData.append(sparseData)
            }
            
        }
        
        func addPoint(point: GraphData.Point, at index: Int) {
            var sparseDataToFinish = [SparseData]()
            
            for sparseData in self.activeSparseData {
                sparseData.addPoint(point: point, at: index)
                if sparseData.isFull {
                    sparseDataToFinish.append(sparseData)
                }
            }
            
            if !sparseDataToFinish.isEmpty {
                for finished in sparseDataToFinish {
                    self.activeSparseData.removeAll { (candidate) -> Bool in
                        return candidate === finished
                    }
                }
                
                self.finishedSparseData.append(contentsOf: sparseDataToFinish)
            }
        }
        
        func finish() -> [Int : GraphData] {
            
            var resultMap = [Int : GraphData]()
            var dataToReduce = [SparseData]()
            
            
            self.finishedSparseData.append(contentsOf: self.activeSparseData)
            for sparseData in self.finishedSparseData {
                
                if sparseData.bitmap == nil {
                    sparseData.points.sort { (point1, point2) -> Bool in
                        return point1.coordinate.x < point2.coordinate.x
                    }
                    
                    resultMap[sparseData.level] = self.initialData.duplicate(withPoints: sparseData.points)
                } else {
                    dataToReduce.append(sparseData)
                }
            }
            
            for (index, point) in self.initialData.points.enumerated() {
                
                for sparseData in dataToReduce {
                    if sparseData.bitmap![index] == true {
                        sparseData.points.append(point)
                    }
                }
            }
            
            for sparseData in dataToReduce {
                resultMap[sparseData.level] = GraphData.init(points: sparseData.points, id: self.initialData.id)
            }
            
            return resultMap
        }
        
        var hasMoreSpace: Bool {
            return self.activeSparseData.count > 0
        }
        
    }
    
    private class CandidateRange {
        let point: GraphData.Point
        let range: Range<Int>
        let index: Int
        let importance: CGFloat
        
        init(point: GraphData.Point, range: Range<Int>, index: Int, importance: CGFloat) {
            self.point = point
            self.range = range
            self.index = index
            self.importance = importance
        }
    }
    
    func fetchSparseDataMap(forChart chartData: ChartData) -> ALTask {
        
        let cacheData = self.cacheData(forChartData: chartData)
        
        if cacheData.sparseDataPerLevelMap == nil {
            let sparseDataPerLevelMap = self.whenLevelsReady(chartData: chartData).then { (result) -> ALTask? in
                let levels = result as! [SparsityLevel]
                
                return self.calculateSparseData(forData: chartData, andLevels: levels)
            }
            
            cacheData.sparseDataPerLevelMap = sparseDataPerLevelMap
        }
        
        let task = cacheData.sparseDataPerLevelMap!.independentTask()
        return task
    }
    
    func calculateSparseData(forData data: GraphData, andLevels levels: [SparsityLevel]) -> ALTask {
        return self.performInBackground { () -> Any in
            let collector = PointsCollector.init(levels: levels, initialData: data)
            self.performDataSparsing(forPoints: data.points, collector: collector)
            let result = collector.finish()
            
            return result
        }
    }
    
    
    // Iterative version of douglas peuker algorithm.
    // It adds important points one by one until collector is full.
    // Does not use tolerance as filter but rather as sort value.
    private func performDataSparsing(forPoints points: [GraphData.Point], collector: PointsCollector)
    {
        if points.count <= 3 {
            for (index, point) in points.enumerated() {
                collector.addPoint(point: point, at: index)
            }
            
            return
        }
        
        var currentRanges = [Range<Int>]()
        
        let initRange = 0 ..< points.count - 1
        currentRanges.append(initRange)
        
        collector.addPoint(point: points.first!, at: 0)
        collector.addPoint(point: points.last!, at: points.count - 1)
        
        let rangesHeap = HeapCollection<CandidateRange>.init { (candidate1, candidate2) -> Bool in
            return candidate1.importance > candidate2.importance
        }
        
        while !currentRanges.isEmpty {
            let range = currentRanges.remove(at: currentRanges.count - 1)
            
            let boundaryStartIndex = range.startIndex
            let boundaryEndIndex = range.endIndex
            
            var mostImportantPointIndex = -1;
            var maxImportance: CGFloat = -1
            var mostImportantPoint: GraphData.Point? = nil
            
            
            let estimator = LinearInportanceEstimator(startCoordinate: points[boundaryStartIndex].coordinate,
                                                      endCoordinate: points[boundaryEndIndex].coordinate)
            
            let rangeToCheck = (boundaryStartIndex + 1) ..< boundaryEndIndex
            
            for i in rangeToCheck {
                let pointToCheck = points[i]
                let importance = estimator.estimateImportance(forCoordinate: pointToCheck.coordinate)
                
                
                if (importance > maxImportance) {
                    mostImportantPointIndex = i
                    maxImportance = importance
                    mostImportantPoint = pointToCheck
                }
                
            }
            
            if mostImportantPointIndex != -1 {
                
                let activeRange = CandidateRange.init(point: mostImportantPoint!, range: range, index: mostImportantPointIndex, importance: maxImportance)
                rangesHeap.push(activeRange)
                
            }
            
            // Handle next iteration
            
            while currentRanges.isEmpty && !rangesHeap.isEmpty {
                let bestRange = rangesHeap.pop()
                if bestRange == nil {
                    return
                }
                
                collector.addPoint(point: bestRange!.point, at: bestRange!.index)
                
                if !collector.hasMoreSpace {
                    return
                }
                
                let bottomRange = bestRange!.range.startIndex ..< bestRange!.index
                if bottomRange.count > 1 {
                    currentRanges.append(bottomRange);
                }
                
                let topRange = bestRange!.index ..< bestRange!.range.endIndex
                if topRange.count > 1 {
                    currentRanges.append(topRange);
                }
            }
            
        }
    }
    
    private class LinearInportanceEstimator
    {
        var dx: CGFloat
        var dy: CGFloat
        
        var levelsDelta: CGFloat
        
        var distance: CGFloat
        
        init(startCoordinate pt1: GraphData.GraphCoordinate, endCoordinate pt2: GraphData.GraphCoordinate)
        {
            dx = pt1.x - pt2.x
            dy = pt1.y - pt2.y
            levelsDelta = pt1.x * pt2.y - pt2.x * pt1.y
            distance = sqrt(dx * dx + dy * dy)
            
        }
        
        func estimateImportance(forCoordinate pt: GraphData.GraphCoordinate) -> CGFloat
        {
            return abs(dy * pt.x - dx * pt.y + levelsDelta) / distance
        }
    }
    
}


private extension DouglasPeukerDataSparser {
    
    func performInBackground(task: @escaping () throws -> Any) -> ALTask {
        
        let executionTask = ALBlockOperation.performOperation { (promise) in
            DispatchQueue.global(qos: .userInitiated).async {
                
                var executionError: Error? = nil
                var result: Any? = nil
                
                do {
                    result = try task()
                } catch let error {
                    executionError = error
                }
                
                DispatchQueue.main.async {
                    if executionError == nil {
                        promise.fulfill(withResult: result!)
                    } else {
                        promise.reject(withError: executionError!)
                    }
                }
            }
        }
        
        return executionTask
    }
}
