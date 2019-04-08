//
//  AppThemeManager.swift
//  GraphPresenter
//
//  Created by Andre on 3/21/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation

final class AppThemeManager {
    
    final class Listener {
        
        fileprivate var onThemeChangedBlock: (AppTheme) -> ()
        init(withOnThemeChangedBlock onThemeChangedBlock: @escaping (AppTheme) -> ()) {
            self.onThemeChangedBlock = onThemeChangedBlock
        }
        
    }
    
    static let shared = AppThemeManager()
    
    private var listeners = [Listener]()
    
    private static let ThemeKey = "UserSettingsKeyTheme"
    
    private var settingsStorage: UserDefaults {
        return UserDefaults.standard
    }
    
    static var currentThemeParams: AppThemeParams {
        return AppThemeManager.shared.currentTheme.params
    }
    
    var currentTheme: AppTheme {
        set {
            if self.currentTheme.name != newValue.name {
                self.settingsStorage.set(newValue.name, forKey: AppThemeManager.ThemeKey)
                
                self.notifiListeners { (listener) in
                    listener.onThemeChangedBlock(newValue)
                }
            }
            
            
        } get {
            let themeName = self.settingsStorage.object(forKey: AppThemeManager.ThemeKey) as? String
            if themeName == nil {
                return AppTheme.defaultTheme
            } else {
                let theme = AppTheme.theme(fromName: themeName!)
                return theme ?? AppTheme.defaultTheme
            }
        }
    }
    
}

extension AppThemeManager {
    
    func addEventListener(_ listener: AppThemeManager.Listener) {
        self.listeners.append(listener)
    }
    
    func removeEventListener(_ listener: AppThemeManager.Listener) {
        self.listeners = self.listeners.filter({ (candidate) -> Bool in
            return candidate !== listener
        })
    }
    
    private func notifiListeners(_ notifyBlock: (Listener) -> Void) {
        self.listeners.forEach { (listener) in
            notifyBlock(listener)
        }
    }
    
}
