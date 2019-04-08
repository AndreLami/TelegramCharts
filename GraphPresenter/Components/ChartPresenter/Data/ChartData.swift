//
//  GraphData.swift
//  ChartPresenter
//
//  Created by Andre on 3/10/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

typealias ChartData = GraphData


@objc class GraphData: NSObject {
    
    class PointDisplay {
        
        let color: UIColor
        
        init(withColor color: UIColor) {
            self.color = color
        }
        
    }
    
    typealias ChartDisplay = GraphDisplay
    class GraphDisplay {
        
        let color: UIColor?
        let lineWidth: CGFloat?
        
        init(withColor color: UIColor?, lineWidth: CGFloat?) {
            self.color = color
            self.lineWidth = lineWidth
        }
        
    }
    
    typealias ChartPoint = Point
    
    @objc(CChartPoint) class Point: NSObject {
        
        @objc let coordinate: GraphCoordinate
        let display: PointDisplay?
        
        let originalData: Any
        
        init(coordinate: GraphCoordinate, originalData: Any, display: PointDisplay?) {
            self.coordinate = coordinate
            self.originalData = originalData
            self.display = display
        }
        
    }
    
    typealias ChartCoordinate = GraphCoordinate
    @objc(ChartCoordinate)  class GraphCoordinate: NSObject {
        
        @objc let x: XAxisType
        @objc let y: YAxisType
        
        init(x: XAxisType, y: YAxisType) {
            self.x = x;
            self.y = y
        }
        
    }
    
    class HighlightDisplay {
        let color: UIColor?
        
        init(withColor color: UIColor?) {
            self.color = color
        }
    }
    
    class Highlight {
        let chartId: String
        let point: Point
        let display: HighlightDisplay?
        
        convenience init(withChartId chartId: String, andPoint point: Point) {
            self.init(withChartId: chartId, point: point, andDisplay: nil)
        }
        
        init(withChartId chartId: String, point: Point, andDisplay display: HighlightDisplay?) {
            self.chartId = chartId
            self.point = point
            self.display = display
        }
    }
    
    var name: String?
    let id: String
    
    let points: [Point]
    let highlight: Point?
    let display: GraphDisplay?
    
    
    
    var tag: String? = nil
    
    var fullId: String {
        return self.id
    }
    
    private var _minY: YAxisType? = nil
    private var _maxY: YAxisType? = nil
    
    init(points: [Point], highlight: Point? = nil, display: GraphDisplay? = nil, id: String) {
        self.points = points
        self.highlight = highlight
        self.display = display
        self.id = id
        
        
    }
    
}

extension GraphData {
    
    func duplicate(withPoints points: [ChartData.ChartPoint]) -> GraphData {
        let duplicate = ChartData.init(points: points, display: self.display, id: self.id)
        duplicate.name = self.name
        duplicate.tag = self.tag
        
        return duplicate
    }
}

extension GraphData {
    var minX: XAxisType {
        return self.points.first?.coordinate.x ?? 0
    }
    
    var maxX: XAxisType {
        return self.points.last?.coordinate.x ?? 0
    }
    
    
    var minY: YAxisType {
        self.resolveMinAndMaxY()
        return _minY!
    }
    
    
    var maxY: YAxisType {
        self.resolveMinAndMaxY()
        return _maxY!
    }
    
    private func resolveMinAndMaxY() {
        if _minY != nil && _maxY != nil {
            return
        }
        
        var minY = YAxisType.maxVal
        var maxY = YAxisType.minVal
        
        for point in self.points {
            if point.coordinate.y > maxY {
                maxY = point.coordinate.y
            }
            
            if point.coordinate.y < minY {
                minY = point.coordinate.y
            }
        }
        
        _minY = minY
        _maxY = maxY
    }
}

extension GraphData {
    
    func findClosestPoint(forCoordinate coordinate: GraphCoordinate) -> Point? {
        if self.points.isEmpty {
            return nil
        }
        
        let index = CollectionUtils.binarySearchInsertIndex(inArray: self.points, value: coordinate.x) { (xVal, candidate) -> Int in
            if xVal < candidate.coordinate.x {
                return -1
            } else if xVal > candidate.coordinate.x {
                return 1
            }
            
            return 0
        }
        
        return self.points[index]
    }
    
    func findNeighbourPoints(forCoordinate coordinate: GraphCoordinate) -> (left: GraphData.Point?, right: GraphData.Point?)? {
        if self.points.isEmpty {
            return nil
        }
        
        let index = CollectionUtils.binarySearchInsertIndex(inArray: self.points, value: coordinate.x) { (xVal, candidate) -> Int in
            if xVal < candidate.coordinate.x {
                return -1
            } else if xVal > candidate.coordinate.x {
                return 1
            }
            
            return 0
        }
        
        let rightPoint: GraphData.Point?
        if index >= self.points.count {
            rightPoint = nil
        } else {
            rightPoint = self.points[index]
        }
        
        let leftPoint: Point?
        if index > 0 {
            leftPoint = self.points[index - 1]
        } else  {
            leftPoint = nil
        }
        
        
        
        return (left: leftPoint, right: rightPoint)
    }
    
}
