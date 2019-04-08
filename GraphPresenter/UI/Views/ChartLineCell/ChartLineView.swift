//
//  ChartLineCell.swift
//  ChartPresenter
//
//  Created by Andre on 3/13/19.
//  Copyright © 2019 BB. All rights reserved.
//

import UIKit

class ChartLineView: UIView {
    
    static let height: CGFloat = 50
    
    private var view: UIView!
    @IBOutlet private var colorView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var separatorView: UIView!
    @IBOutlet private var checkmarkView: UIView!
    
    var selected: Bool = true {
        didSet {
            self.checkmarkView.isHidden = !self.selected
        }
    }
    
    init(with name: String, color: UIColor?) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: 320, height: ChartLineView.height))
        self.nibSetup()
        
        self.colorView.layer.cornerRadius = 3
        self.titleLabel.text = name
        self.colorView.backgroundColor = color
        self.selected = true
        
        self.applyTheme(AppThemeManager.shared.currentTheme, animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func nibSetup() {
        
        self.view = loadViewFromNib()
        self.view.frame = self.bounds
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.backgroundColor = .clear
        
        self.addSubview(self.view)
        
        let viewLeadingConstraint = self.view.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        viewLeadingConstraint.constant = 0
        viewLeadingConstraint.isActive = true
        
        let viewTralingConstraint = self.view.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        viewTralingConstraint.constant = 0
        viewTralingConstraint.isActive = true
        
        let viewTopConstraint = self.view.topAnchor.constraint(equalTo: self.topAnchor)
        viewTopConstraint.constant = 0
        viewTopConstraint.isActive = true
        
        let viewBotConstraint = self.bottomAnchor.constraint(greaterThanOrEqualTo: self.view.bottomAnchor)
        viewBotConstraint.constant = 0
        viewBotConstraint.isActive = true
    }
    
    private func loadViewFromNib() -> UIView {
        let nib = UINib(nibName: "ChartLineView", bundle: Bundle.main)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return nibView
    }
    
    
    func applyTheme(_ appTheme: AppTheme, animated: Bool) {
        
        let applyBlock = {
            let currentThemeParams = AppThemeManager.currentThemeParams
            self.backgroundColor = currentThemeParams.secondaryBackgroundColor
            self.titleLabel.textColor = AppThemeManager.shared.currentTheme.isDay ? .black : .white
            self.separatorView.backgroundColor = currentThemeParams.primaryBackgroundColor
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .beginFromCurrentState, animations: {
                applyBlock()
            }, completion: nil)
        } else {
            applyBlock()
        }
        
    }

    
    func hideSeparator(hide: Bool) {
        self.separatorView.isHidden = hide
    }
}
