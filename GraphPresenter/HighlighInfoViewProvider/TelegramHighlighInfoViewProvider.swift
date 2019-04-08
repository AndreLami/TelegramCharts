//
//  HighlighInfoViewProvider.swift
//  ChartPresenter
//
//  Created by Andre on 3/20/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

class TelegramHighlightInfoViewProvider {
    
    private lazy var monthFormatter: DateFormatter = {
        let monthFormatter = DateFormatter.init()
        monthFormatter.dateFormat = "LLL dd"

        return monthFormatter
    }()
    
    private lazy var yearFormatter: DateFormatter = {
        let yearFormatter = DateFormatter.init()
        yearFormatter.dateFormat = "yyyy"
        
        return yearFormatter
    }()
    
}

extension TelegramHighlightInfoViewProvider: IHighlightInfoViewProvider {
    
    
    
    func provideHighlightInfoView(_ mode: String) -> UIView {
        let theme = AppTheme.theme(fromName: mode)!
        let view = HighlightInfoView.create(withYearFormatter: self.yearFormatter,
                                            monthFormatter: self.monthFormatter,
                                            andTheme: theme)
        
        return view
    }
    
    func updateHighlightInfoView(_ view: UIView, withHighlights highlights: [ChartData.Highlight]) {
        let highlightView = view as! HighlightInfoView
        
        guard let highlight = highlights.first else {
            return
        }
        
        let xValue = highlight.point.statisticPointData.x
        highlightView.updateStatiscs(time: xValue, andHiglights: highlights)
    }
    
    func updateHighlightInfoView(_ view: UIView, forMode mode: String, animated: Bool) {
        let highlightView = view as! HighlightInfoView
        
        let theme = AppTheme.theme(fromName: mode)!
        highlightView.updateTheme(theme, animated: animated)
    }
    
}
