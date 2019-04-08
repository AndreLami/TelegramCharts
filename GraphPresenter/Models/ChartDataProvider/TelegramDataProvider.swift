//
//  TelegramDataProvider.swift
//  ChartPresenter
//
//  Created by Andre on 3/17/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

//class GraphDataProviderClass {
//    
//    private var chartsData: StatisticsJsonParser2?
//    
//    private var pointsToNameMap = [String : [GraphData.Point]]()
//    private var pointsToNameMapTemp = [String : [GraphData.Point]]()
//    private var displayToNameMap = [String : GraphData.GraphDisplay]()
//    
//    private var highlightsToNameMapTemp = [String : GraphData.Point]()
//    
//    private (set) var currentX: CGFloat = 0
//    private (set) var currentY: CGFloat = 0
//    
//    private var yNamesArray = [String]()
//    private var yShowLineToNameMap = [String : Bool]()
//    
//    private var currentChart: ChartData2?
//    
//    init() {
//        
//        self.chartsData = StatisticsJsonParser2.init("chart_data")
//        
//        if let data = self.chartsData?.charts.last {
//            
//            self.currentChart = data
//            
//            data.namesArray.forEach { (name) in
//                if let yData = data.yValuesMapToName[name] {
//                    
//                    self.yNamesArray.append(name)
//                    self.yShowLineToNameMap[name] = true
//                    
//                    if self.pointsToNameMap[name] == nil {
//                        self.pointsToNameMap[name] = Array<GraphData.Point>()
//                    }
//                    
//                    self.displayToNameMap[name] = GraphData.GraphDisplay.init(withColor: data.colorMapToName[name], lineWidth: 1.5)
//                    
//                    yData.enumerated().forEach({ (arg) in
//                        if self.currentY < arg.element {
//                            self.currentY = arg.element
//                        }
//                        let point = GraphData.Point.init(coordinate:GraphData.GraphCoordinate(x: XAxisType(arg.offset), y: YAxisType(arg.element)), originalData: data.xDataRaw[arg.offset], display:GraphData.PointDisplay.init(withColor: data.colorMapToName[name] ?? .white))
//                        self.pointsToNameMap[name]!.append(point)
//                        
//                        if Int(self.currentX) < arg.offset {
//                            self.currentX = CGFloat(arg.offset)
//                        }
//                    })
//                }
//            }
//            
//            self.yNamesArray.sort()
//        }
//    }
//    
//    var yStringValues: [String] {
//        get {
//            return self.yNamesArray
//        }
//    }
//    
//    func colorForYName(name: String) -> UIColor {
//        return self.displayToNameMap[name]?.color ?? .black
//    }
//    
//    func visibilityForYName(name: String) -> Bool {
//        return self.yShowLineToNameMap[name] ?? false
//    }
//}

//extension GraphDataProviderClass: IChartsDataProvider {
//
//
//    func viewPortChanged() {
//        self.highlightsToNameMapTemp.removeAll()
//    }
//
//    func provideHighlightData(forCoordinate: GraphData.GraphCoordinate) -> HighlightViewResult {
//
//        let graphDataIndex = Int(round(forCoordinate.x))
//
//        let dateAttributedString = NSMutableAttributedString.init()
//
//        if let xDateRaw = self.currentChart?.xDataRaw[graphDataIndex] {
//
//            let dateFormatterYear = DateFormatter.init()
//            dateFormatterYear.dateFormat = "yyyy"
//
//            let dateFormatterMonth = DateFormatter.init()
//            dateFormatterMonth.dateFormat = "LLL dd"
//
//            let textColor = UserSettings.sharedSettings.dayMode == true ? UserSettings.dayHighlightTextColor : UserSettings.nightHighlightTextColor
//
//            dateAttributedString.append(NSMutableAttributedString.init(string: dateFormatterMonth.string(from: xDateRaw), attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12, weight: .bold), NSAttributedString.Key.foregroundColor : textColor]))
//            dateAttributedString.append(NSMutableAttributedString.init(string: "\n\(dateFormatterYear.string(from: xDateRaw))", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12, weight: .light), NSAttributedString.Key.foregroundColor : textColor]))
//        }
//
//        var points = [String : GraphData.Point]()
//        var sortedKeys = [String]()
//
//        self.pointsToNameMapTemp.forEach { (key, value) in
//            points[key] = value[graphDataIndex]
//            sortedKeys.append(key)
//        }
//
//        sortedKeys.sort()
//
//        let valuesAttributedString = NSMutableAttributedString.init()
//
//        sortedKeys.forEach { (key) in
//            if let data = points[key] {
//                if self.yShowLineToNameMap[key] == true {
//                    self.highlightsToNameMapTemp[key] = data
//                    let color = self.displayToNameMap[key]?.color ?? .white
//                    if valuesAttributedString.string.count > 0 {
//                        valuesAttributedString.append(NSAttributedString.init(string: "\n"))
//                    }
//                    valuesAttributedString.append(NSAttributedString.init(string: "\(data.coordinate.y)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12, weight: .bold), NSAttributedString.Key.foregroundColor : color]))
//                }
//            }
//        }
//
//        return (dateAttributedString, valuesAttributedString)
//    }
//
//
//    func provideData(forViewPort: ViewPort, showHighlight: Bool) -> [GraphData] {
//
//        var pointsToNameMapTemp = [String : [GraphData.Point]]()
//
//        self.yNamesArray.forEach { (name) in
//
//            if self.yShowLineToNameMap[name] == true {
//
//                if pointsToNameMapTemp[name] == nil {
//                    pointsToNameMapTemp[name] = Array<GraphData.Point>()
//                }
//
//                let startIndex = Int(forViewPort.x)
//                let endIndex = Int(forViewPort.xEnd)
//
//                if let dataArray = self.pointsToNameMap[name] {
//                    for i in startIndex..<endIndex {
//                        if dataArray.count - 1 >= endIndex {
//                            pointsToNameMapTemp[name]!.append(dataArray[i])
//                        }
//                    }
//                }
//            }
//        }
//
//        self.pointsToNameMapTemp = pointsToNameMapTemp
//
//        var graphDataArray = Array<GraphData>()
//
//        for name in self.yNamesArray {
//            if let points = pointsToNameMapTemp[name] {
//                graphDataArray.append(GraphData.init(points: points, highlight: showHighlight ? self.highlightsToNameMapTemp[name] : nil, display: self.displayToNameMap[name]!, id: name))
//            }
//        }
//
//        return graphDataArray
//    }
//
//    func findTopCoordinate() -> GraphData.GraphCoordinate {
//
//        var topCoordinate = GraphData.GraphCoordinate.init(x: 0, y: 0)
//
//        self.highlightsToNameMapTemp.keys.forEach { (key) in
//            if self.yShowLineToNameMap[key] == true {
//                if let point = self.highlightsToNameMapTemp[key] {
//                    if point.coordinate.y > topCoordinate.y {
//                        topCoordinate = point.coordinate
//                    }
//                }
//            }
//        }
//
//        return topCoordinate
//    }
//
//    func updateGraphVisibility(for index: Int) {
//        let name = self.yNamesArray[index]
//        self.yShowLineToNameMap[name] = !(self.yShowLineToNameMap[name] ?? false)
//    }
//}
