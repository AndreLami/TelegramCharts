//
//  TelegramYAxisDataLabeler.swift
//  ChartPresenter
//
//  Created by Andre on 3/15/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation

class TelegramYAxisDataLabeler: IGraphCoordinateYLabeler {
    
    func makeLabel(forCoordinate yValue: YAxisType, inViewPort viewPort: ViewPort) -> String {
        return "\(Int(yValue))"
    }
    
}

class TelegramXAxisDataLabeler: IGraphCoordinateXLabeler {
    
    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter.init()
        formatter.dateFormat = "LLL dd"
        return formatter
    }()
    
    func makeLabel(forCoordinate xValue: XAxisType, inViewPort viewPort: ViewPort) -> String {
        let time = TimeInterval(xValue)
        let date = Date.init(timeIntervalSince1970: time)
        let label = formatter.string(from: date)
        
        return label
    }
    
}
