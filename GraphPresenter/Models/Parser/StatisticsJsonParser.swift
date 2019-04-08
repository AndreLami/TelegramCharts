//
//  StatisticsJsonParser.swift
//  ChartPresenter
//
//  Created by Andre on 3/19/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

final class StatisticJsonParser {
    
    private let NameKey = "names"
    private let ColumnsKey = "columns"
    private let TypesKey = "types"
    private let ColorsKey = "colors"
    
    private let ChartElementTypeY = "line"
    private let ChartElementTypeX = "x"
    
    enum ParserError: Error {
        case FileNotFound
        case FileCurrupted
        case IncorrectJsonFormat
        case IncorrectDataFormat
    }
    
    func parse(data: Data) throws -> [Statistic] {
        let rawData: Any
        do {
            rawData = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            
        } catch {
            throw ParserError.IncorrectJsonFormat
        }
        
        guard let jsonData = rawData as? Array<Dictionary<String, AnyObject>> else {
            throw ParserError.IncorrectDataFormat
        }
        
        var stats = [Statistic]()
        for statisticData in jsonData {
            let statatistic = try self.parse(statisticData: statisticData)
            if statatistic != nil {
                stats.append(statatistic!)
            }
        }
        
        return stats
        
    }
    
    private func parse(statisticData data: Dictionary<String, AnyObject>) throws -> Statistic? {
        let formatError = ParserError.IncorrectDataFormat
        
        guard let names = data[NameKey] as? [String: String] else {
            throw formatError
        }
        
        guard let colors = data[ColorsKey] as? [String: String] else {
            throw formatError
        }
        
        guard let types = data[TypesKey] as? [String: String] else {
            throw formatError
        }
        
        guard let columns = data[ColumnsKey] as? [[Any]] else {
            throw formatError
        }
        
        // Resolve x type name and all chart ids
        var xTypeKey: String!
        var chartIds = [String]()
        
        for (id, type) in types {
            if type == ChartElementTypeX {
                xTypeKey = id
            } else if type == ChartElementTypeY {
               chartIds.append(id)
            }
        }
        
        if xTypeKey == nil {
            throw formatError
        }
        
        // Group all data by id and remove first val as data id
        var dataIdToDataMap = [String : [Any]]()
        for i in 0 ..< columns.count {
            var column = columns[i]
            guard let dataId = column.remove(at: 0) as? String else {
                throw formatError
            }
            
            
            if !column.isEmpty {
                dataIdToDataMap[dataId] = column
            }
        }
        
        guard let xValues = dataIdToDataMap[xTypeKey] else {
            throw formatError
        }
        
        var chartIdToChartPointsMap = [String: [ChartData.ChartPoint]]()
        chartIds.forEach { (id) in
            chartIdToChartPointsMap[id] = [ChartData.ChartPoint]()
        }
        
        // Create chart points
        for i in 0 ..< xValues.count {
            let xValue = xValues[i] as! StatisticXType
            
            for chartId in chartIds {
                let yValue = dataIdToDataMap[chartId]![i] as! StatisticYType
                
                
                let xTime = xValue / 1000
                
                let x = XAxisType(xTime)
                let y = YAxisType(yValue)
                if y.isNaN || x.isNaN {
                    continue
                }
                
                let chartCoordinate = ChartData.ChartCoordinate.init(x: x, y: y)
                let originalData = (x: xTime, y: yValue)
                let chartPoint = ChartData.Point.init(coordinate: chartCoordinate, originalData: originalData, display: nil)
                chartIdToChartPointsMap[chartId]?.append(chartPoint)
            }
        }
        
        // Create charts
        
        var charts = [ChartData]()
        
        for chartId in chartIds {
            let chartName = names[chartId]
            let chartPoints = chartIdToChartPointsMap[chartId]!
            let hexColor = colors[chartId]
            let color = hexColor != nil ? UIColor.init(hex: hexColor!) : nil
            
            let chartDisplay = ChartData.ChartDisplay.init(withColor: color, lineWidth: nil)
            
            let chart = ChartData.init(points: chartPoints, display: chartDisplay, id: chartId)
            chart.name = chartName
            
            charts.append(chart)
        }
        
        charts = charts.sorted { $0.name! < $1.name! }
        
        
        return Statistic.init(charts: charts)
    }
}

extension StatisticJsonParser {
    
    static  func fromBundlePath(_ path: String) throws -> [Statistic] {
        if let path = Bundle.main.path(forResource:path, ofType: nil) {
            var data: Data
            do {
                data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            } catch {
                print(error)
                throw ParserError.FileCurrupted
            }
            
            let parser = StatisticJsonParser.init()
            return try parser.parse(data: data)
            
        } else {
            throw ParserError.FileNotFound
        }
    }
    
}
