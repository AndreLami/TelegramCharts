//
//  UserSettings.swift
//  ChartPresenter
//
//  Created by Andre on 3/14/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

final class UserSettings {
    
    static let dayMainBackgroundColor = UIColor.init(red: 239.0 / 255.0, green: 239.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0)
    static let nightMainBackgroundColor = UIColor.init(red: 24.0 / 255.0, green: 34.0 / 255.0, blue: 45.0 / 255.0, alpha: 1.0)
    
    static let daySubviewBackgroundColor = UIColor.white
    static let nightSubviewBackgroundColor = UIColor.init(red: 33.0 / 255.0, green: 47.0 / 255.0, blue: 63.0 / 255.0, alpha: 1.0)
    
    static let dayNetColor = UIColor.init(red: 243.0 / 255.0, green: 243.0 / 255.0, blue: 243.0 / 255.0, alpha: 1.0)
    static let nightNetColor = UIColor.init(red: 27.0 / 255.0, green: 39.0 / 255.0, blue: 52.0 / 255.0, alpha: 1.0)
    
    static let daySeparatorColor = UIColor.init(red: 207.0 / 255.0, green: 209.0 / 255.0, blue: 210.0 / 255.0, alpha: 1.0)
    static let nightSeparatorColor = UIColor.init(red: 19.0 / 255.0, green: 27.0 / 255.0, blue: 35.0 / 255.0, alpha: 1.0)
    
    static let dayHighlightColor = UIColor.init(red: 247.0 / 255.0, green: 247.0 / 255.0, blue: 253.0 / 255, alpha: 1.0)
    static let nightHighlightColor = UIColor.init(red: 26.0 / 255.0, green: 40.0 / 255.0, blue: 55.0 / 255.0, alpha: 1.0)
    
    static let dayHighlightTextColor = UIColor.init(red: 109.0 / 255.0, green: 109.0 / 255.0, blue: 114.0 / 255.0, alpha: 1.0)
    static let nightHighlightTextColor = UIColor.init(red: 254.0 / 255.0, green: 254.0 / 255.0, blue: 254.0 / 255.0, alpha: 1.0)
    
    private static let ThemeKey = "UserSettingsKeyTheme"
    
    static let sharedSettings = UserSettings()
    
    init() {
        
    }
   
    
    var appTheme: AppTheme {
        set {
            UserDefaults.standard.set(newValue.name, forKey: UserSettings.ThemeKey)
        } get {
            let themeName = UserDefaults.standard.object(forKey: UserSettings.ThemeKey) as? String
            if themeName == nil {
                return AppTheme.defaultTheme
            } else {
                let theme = AppTheme.theme(fromName: themeName!)
                return theme ?? AppTheme.defaultTheme
            }
        }
    }
    
}
