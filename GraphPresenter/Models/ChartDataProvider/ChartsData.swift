//
//  ChartData.swift
//  ChartPresenter
//
//  Created by Andre on 3/12/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

final class StatisticsJsonParser2 {
    
    private (set) var charts = [ChartData2]()
    
    init?(_ jsonFileName: String) {
        if let path = Bundle.main.path(forResource:jsonFileName, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                
                if let jsonResult = jsonResult as? Array<Dictionary<String, AnyObject>> {
                    self.parseJsonResult(jsonResult)
                }
            } catch {
                print(error)
                return nil
            }
        }
    }
}

private extension StatisticsJsonParser2 {
    
    func parseJsonResult(_ result: Array<Dictionary<String, AnyObject>>) {
        result.forEach { (chartData) in
            if let chartData = ChartData2.init(chartData) {
                self.charts.append(chartData)
            }
        }
    }
    
}

final class ChartData2 {
    
    var xName = ""
    var xDataRaw = Array<Date>()
    var xData = Array<String>()
    var yValuesMapToName = Dictionary<String, Array<CGFloat>>()
    var typesMapToName = Dictionary<String, String>()
    var namesMapToName = Dictionary<String, String>()
    var colorMapToName = Dictionary<String, UIColor>()
    var namesArray = Array<String>()
    
    init?(_ chartData: Dictionary<String, AnyObject>) {
        
        if let types = chartData["types"] as? [String : String] {
            self.typesMapToName = types
        }
        
        if let names = chartData["types"] as? [String : String] {
            self.namesMapToName = names
        }
        
        if let columns = chartData["columns"] as? Array<Array<AnyObject>> {
            
            columns.forEach { (valuesArray) in
                
                if let name = valuesArray.first as? String {
                    
                    if let nameOfArray = self.typesMapToName[name] {
                        
                        if nameOfArray == "x" {
                            
                            let dateFormatter = DateFormatter.init()
                            dateFormatter.dateFormat = "LLL dd"
                            
                            self.xName = name
                            
                            for i in 1..<valuesArray.count {
                                if let timeinterval = valuesArray[i] as? TimeInterval {
                                    let date = Date.init(timeIntervalSince1970: timeinterval)
                                    self.xDataRaw.append(date)
                                    let dateString = dateFormatter.string(from: date)
                                    self.xData.append(dateString)
                                }
                            }
                            
                        } else if nameOfArray == "line" {
                            
                            self.namesArray.append(name)
                            
                            for j in 1..<valuesArray.count {
                                if self.yValuesMapToName[name] == nil {
                                    self.yValuesMapToName[name] = Array<CGFloat>()
                                }
                                if let value = valuesArray[j] as? CGFloat {
                                    self.yValuesMapToName[name]!.append(value)
                                }

                            }
                        }
                    }
                }
            }
        }
        
        if let colors = chartData["colors"] as? [String : String] {
            self.namesArray.forEach { (name) in
                if let colorString = colors[name] {
                    if let color = UIColor.init(hex: colorString) {
                        self.colorMapToName[name] = color
                    }
                }
            }
        }
    }
    
}
