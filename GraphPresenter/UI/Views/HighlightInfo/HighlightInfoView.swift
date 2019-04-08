//
//  HighlightInfoView.swift
//  ChartPresenter
//
//  Created by Andre on 3/20/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

class HighlightInfoView: UIView {
    
    private (set) var dateLabel: UILabel!
    private (set) var valuesLabel: UILabel!
    
    private (set) var theme: AppTheme!
    
    private var yearFormatter: DateFormatter!
    private var monthFormatter: DateFormatter!
    
    private var statisticTime: StatisticXType?
    private var highlights: [ChartData.Highlight]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
}

extension HighlightInfoView {
    
    static func create(withYearFormatter yearFormatter: DateFormatter,
                       monthFormatter: DateFormatter,
                       andTheme theme: AppTheme) -> HighlightInfoView {
        
        let view = HighlightInfoView()
        view.yearFormatter = yearFormatter
        view.monthFormatter = monthFormatter
        view.theme = theme
        
        view.layer.cornerRadius = 4.0
//        view.layer.masksToBounds = true
        view.backgroundColor = view.currentModeBackgroundColor
        
        
        return view
    }
    
}
extension HighlightInfoView {
    
    func updateStatiscs(time: StatisticXType, andHiglights highlights: [ChartData.Highlight]) {
        self.statisticTime = time
        self.highlights = highlights
        
        self.applyValues(animated: false)
    }
    
    func updateTheme(_ theme: AppTheme, animated: Bool) {
        self.theme = theme
        self.applyMode(animated: animated)
    }
    
}
private extension HighlightInfoView {
    
    func setup() {
        let edgeOffset: CGFloat = 8
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let dateLabel = UILabel()
        dateLabel.numberOfLines = 0
        self.dateLabel = dateLabel
        
        let valuesLabel = UILabel()
        
        valuesLabel.numberOfLines = 0
        self.valuesLabel = valuesLabel
        
        self.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        let dateLeadingConstraint = dateLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        dateLeadingConstraint.constant = edgeOffset
        dateLeadingConstraint.isActive = true
        
        let dateTopConstraint = dateLabel.topAnchor.constraint(equalTo: self.topAnchor)
        dateTopConstraint.constant = edgeOffset
        dateTopConstraint.isActive = true
        
        let dateBotConstraint = self.bottomAnchor.constraint(greaterThanOrEqualTo: dateLabel.bottomAnchor)
        dateBotConstraint.constant = edgeOffset
        dateBotConstraint.isActive = true
        
        dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        dateLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        let dateBottomTieConstraint = dateLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        dateBottomTieConstraint.priority = UILayoutPriority.defaultLow
        
        self.addSubview(valuesLabel)
        valuesLabel.translatesAutoresizingMaskIntoConstraints = false
        let valuesTrailingConstraint = valuesLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        valuesTrailingConstraint.constant = -edgeOffset
        valuesTrailingConstraint.isActive = true
        
        let valuesTopConstraint = valuesLabel.topAnchor.constraint(equalTo: self.topAnchor)
        valuesTopConstraint.constant = edgeOffset
        valuesTopConstraint.isActive = true
        
        let valuesBottomConstraint = self.bottomAnchor.constraint(greaterThanOrEqualTo: valuesLabel.bottomAnchor)
        valuesBottomConstraint.constant = edgeOffset
        valuesBottomConstraint.isActive = true
        
        valuesLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        valuesLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        let spacingConstraint = valuesLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor)
        spacingConstraint.constant = 15
        spacingConstraint.isActive = true
        
        
        let valuesBottomTieConstraint = valuesLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        valuesBottomTieConstraint.priority = UILayoutPriority.defaultLow
        
        
    }
    
    func applyMode(animated: Bool) {
        self.applyValues(animated: animated)
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .beginFromCurrentState, animations: {
                self.backgroundColor = self.currentModeBackgroundColor
            }, completion: nil)
            
        } else {
            self.backgroundColor = self.currentModeBackgroundColor
        }
        
    }
    
    func applyValues(animated: Bool = true) {
        guard let statisticsTime = self.statisticTime, let highlights = self.highlights else {
            return
        }
        
        let statDate = Date.init(timeIntervalSince1970: TimeInterval(statisticsTime))
        
        let dateAttributedString = NSMutableAttributedString.init()
        
        let dateFormatterYear = self.yearFormatter!
        let dateFormatterMonth = self.monthFormatter!
        
        let paragraphStyleRight = NSMutableParagraphStyle()
        paragraphStyleRight.lineSpacing = 2.5
        paragraphStyleRight.alignment = .left
        
        let dateColor = self.currentModeDateTextColor
        
        let monthText = NSMutableAttributedString.init(string: dateFormatterMonth.string(from: statDate), attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13, weight: .bold), NSAttributedString.Key.foregroundColor : dateColor])
        let yearText = NSMutableAttributedString.init(string: "\n" + dateFormatterYear.string(from: statDate), attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13, weight: .regular), NSAttributedString.Key.foregroundColor : dateColor])
        
        dateAttributedString.append(monthText)
        dateAttributedString.append(yearText)
        dateAttributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyleRight, range:NSMakeRange(0, dateAttributedString.length))
        
        self.dateLabel.attributedText = dateAttributedString
        
        
        let valuesAttributedString = NSMutableAttributedString.init()
        
        let paragraphStyleLeft = NSMutableParagraphStyle()
        paragraphStyleLeft.lineSpacing = 2.5
        paragraphStyleLeft.alignment = .right
        
        for highlight in highlights {
            let color = highlight.display?.color ?? .white
            
            if valuesAttributedString.string.count > 0 {
                valuesAttributedString.append(NSAttributedString.init(string: "\n"))
            }
            
            let value = highlight.point.statisticPointData.y
            valuesAttributedString.append(NSAttributedString.init(string: "\(value)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13, weight: .bold), NSAttributedString.Key.foregroundColor : color]))
            valuesAttributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyleLeft, range:NSMakeRange(0, valuesAttributedString.length))
        }
        
        self.valuesLabel.attributedText = valuesAttributedString
        
        
    }
    
    
}

private extension HighlightInfoView {
    
    var currentModeDateTextColor: UIColor {
        if self.theme.isDay {
            return UIColor.init(red: 109.0 / 209.0, green: 109.0 / 255.0, blue: 114.0 / 255.0, alpha: 1.0)
        } else {
            return UIColor.init(red: 254.0 / 255.0, green: 254.0 / 255.0, blue: 254.0 / 255, alpha: 1.0)
        }
    }
    
    var currentModeBackgroundColor: UIColor {
        if self.theme.isDay {
            return UIColor.init(red: 247.0 / 255.0, green: 247.0 / 255.0, blue: 253.0 / 255, alpha: 1.0)
        } else {
            return UIColor.init(red: 26.0 / 209.0, green: 40.0 / 255.0, blue: 55.0 / 255.0, alpha: 1.0)
        }
        
        
    }
    
}
