//
//  StatisticsViewController.swift
//  GraphPresenter
//
//  Created by Andre on 3/22/19.
//  Copyright © 2019 BB. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController {
    
    @IBOutlet weak var stackContainerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
}

private extension StatisticsViewController {
    
    func setupUI() {
        
        let storage = StatisticsStorage()
        storage.availableStatistics.then { (result) -> ALTask? in
            let availableStatistics = result as! [Statistic]
            self.statsRready(availableStatistics)
            
            return nil
        }
       
        
        self.applyTheme(AppThemeManager.shared.currentTheme, animated: false)
    }
    
    func statsRready(_ availableStatistics: [Statistic]) {
        
        
        self.stackContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        var prevView: UIView? = nil
        
        let containerView = self.stackContainerView!
        
        availableStatistics.enumerated().forEach { (index, statistic) in
            
            let statisticContainer = UIView()
            statisticContainer.translatesAutoresizingMaskIntoConstraints = false
            
            containerView.addSubview(statisticContainer)
            
            statisticContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
            statisticContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
            
            if (prevView != nil) {
                statisticContainer.topAnchor.constraint(equalTo: prevView!.bottomAnchor).isActive = true
            } else {
                statisticContainer.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            }
            
            let viewController = StatisticViewController.initializator(statistic: statistic)
            ViewControllerPresenter.init().presentViewController(viewController, parentViewController: self, container: statisticContainer, animator: nil)
            
            prevView = statisticContainer
            
            if index == availableStatistics.count - 1 {
                statisticContainer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
            }
        }
    }
    
    func setupData() {
        let themeUpdateListener = AppThemeManager.Listener { [weak self] theme in
            self?.applyTheme(theme, animated: true)
        }
        
        AppThemeManager.shared.addEventListener(themeUpdateListener)
    }
    
}


private extension StatisticsViewController {
    
    func applyTheme(_ theme: AppTheme, animated: Bool) {
        let params = theme.params
        
        let applyThemeBlock = {
            self.view.backgroundColor = params.primaryBackgroundColor
            
            self.navigationController?.navigationBar.barTintColor = nil
            let navigationViewTextColor = theme.isDay ? UIColor.black : UIColor.white
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : navigationViewTextColor]
            let navigationBarStyle: UIBarStyle = theme.isDay ? .default : .black
            self.navigationController?.navigationBar.barStyle = navigationBarStyle
            let tintColor = theme.isDay ? nil : params.secondaryBackgroundColor
            self.navigationController?.navigationBar.barTintColor = tintColor
            
            self.setNeedsStatusBarAppearanceUpdate()
            self.navigationController?.setNeedsStatusBarAppearanceUpdate()
        }
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                applyThemeBlock()
            }
        } else {
            applyThemeBlock()
        }
    }
    
}
