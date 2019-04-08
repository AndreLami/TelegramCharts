//
//  AppTheme.swift
//  GraphPresenter
//
//  Created by Andre on 3/21/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

enum AppTheme {
    
    static let dayThemeName = "Day"
    static let nightThemeName = "Night"
    
    case day
    case night
    
    static var dayThemeParams: AppThemeParams = AppTheme.createDayThemeParams()
    static var nightThemeParams: AppThemeParams = AppTheme.createNightThemeParams()
    
}

final class AppThemeParams {
    
    let statisticsInfoViewBackgroundColor: UIColor
    let statisticsInfoViewDateTextColor: UIColor
    
    let primaryBackgroundColor: UIColor
    let secondaryBackgroundColor: UIColor
    
    let chartDisplaParams: ChartDisplayParams
    
    init(statisticsInfoViewBackgroundColor: UIColor,
         statisticsInfoViewDateTextColor: UIColor,
         primaryBackgroundColor: UIColor,
         secondaryBackgroundColor: UIColor,
         chartDisplaParams: ChartDisplayParams) {
        
        self.statisticsInfoViewBackgroundColor = statisticsInfoViewBackgroundColor
        self.statisticsInfoViewDateTextColor = statisticsInfoViewDateTextColor
        self.primaryBackgroundColor = primaryBackgroundColor
        self.secondaryBackgroundColor = secondaryBackgroundColor
        self.chartDisplaParams = chartDisplaParams
    }
    
}

extension AppTheme {
    
    static var defaultTheme: AppTheme {
        return .day
    }
    
    var isDay: Bool {
        switch self {
            case .day:
                return true
            default:
                return false
        }
    }
    
    var isNight: Bool {
        switch self {
        case .night:
            return true
        default:
            return false
        }
    }
    
    var name: String {
        if self.isDay {
            return AppTheme.dayThemeName
        } else {
            return AppTheme.nightThemeName
        }
    }
    
    static func theme(fromName name: String) -> AppTheme? {
        if name == dayThemeName {
            return .day
        } else if name == nightThemeName {
            return .night
        }
        
        return nil
    }
    
    var params: AppThemeParams {
        if self.isDay {
            return AppTheme.dayThemeParams
        } else {
            return AppTheme.nightThemeParams
        }
    }
    
    
}

extension AppTheme {
    
    static func createDayThemeParams() -> AppThemeParams {
        let chartParams = self.createDayThemeChartDisplayParams()
        
        let themeParams = AppThemeParams.init(statisticsInfoViewBackgroundColor: UIColor.blue,
                                              statisticsInfoViewDateTextColor: UIColor.blue,
                                              primaryBackgroundColor: UIColor.init(red: 239.0 / 255.0, green: 239.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0),
                                              secondaryBackgroundColor: UIColor.white,
                                              chartDisplaParams: chartParams)
        
        return themeParams
    }
    
    static func createNightThemeParams() -> AppThemeParams {
        let chartParams = self.createDayThemeChartDisplayParams()
        
        let themeParams = AppThemeParams.init(statisticsInfoViewBackgroundColor: UIColor.blue,
                                              statisticsInfoViewDateTextColor: UIColor.blue,
                                              primaryBackgroundColor: UIColor.init(red: 24.0 / 255.0, green: 34.0 / 255.0, blue: 45.0 / 255.0, alpha: 1.0),
                                              secondaryBackgroundColor: UIColor.init(red: 33.0 / 255.0, green: 47.0 / 255.0, blue: 63.0 / 255.0, alpha: 1.0),
                                              chartDisplaParams: chartParams)
        
        return themeParams
    }
    
    static func createChartDisplayParams(forTheme theme: AppTheme, lineWidth: CGFloat = 1.0) -> ChartDisplayParams {
        if theme.isDay {
            return self.createDayThemeChartDisplayParams(lineWidth: lineWidth)
        } else {
            return self.createNightThemeChartDisplayParams(lineWidth: lineWidth)
        }
    }
    
    private static func createDayThemeChartDisplayParams(lineWidth: CGFloat = 1.0) -> ChartDisplayParams {
        let params = ChartDisplayParams.init(primaryBackgroundColor: UIColor.white,
                                             primaryTextColor: UIColor.init(red: 109.0 / 255.0, green: 109.0 / 255.0, blue: 114.0 / 255.0, alpha: 1.0),
                                             primaryAxisColor: UIColor.init(red: 207.0 / 255.0, green: 209.0 / 255.0, blue: 210.0 / 255.0, alpha: 1.0),
                                             secondaryAxisColor: UIColor.init(red: 240.0 / 255.0, green: 240.0 / 255.0, blue: 240.0 / 255.0, alpha: 1.0),
                                             lineWidth: lineWidth)
        
        return params
    }
    
    private static func createNightThemeChartDisplayParams(lineWidth: CGFloat = 1.0) -> ChartDisplayParams {
        let params = ChartDisplayParams.init(primaryBackgroundColor: UIColor.init(red: 33.0 / 255.0, green: 47.0 / 255.0, blue: 63.0 / 255.0, alpha: 1.0),
                                             primaryTextColor: UIColor.init(red: 75.0 / 255.0, green: 90.0 / 255.0, blue: 106.0 / 255.0, alpha: 1.0),
                                             primaryAxisColor: UIColor.init(red: 15.0 / 255.0, green: 21.0 / 255.0, blue: 26.0 / 255.0, alpha: 1.0),
                                             secondaryAxisColor: UIColor.init(red: 24.0 / 255.0, green: 33.0 / 255.0, blue: 45.0 / 255.0, alpha: 1.0),
                                             lineWidth: lineWidth)
        
        return params
    }
    
}
