//
//  GraphPresenterOptions.swift
//  GraphPresenter
//
//  Created by Andre on 3/15/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

enum ChartDisplayMode {
    
    case day
    case night
    
}

protocol IGraphCoordinateXLabeler {
    
    func makeLabel(forCoordinate xValue: XAxisType, inViewPort viewPort: ViewPort) -> String
    
}

protocol IGraphCoordinateYLabeler {
    
    func makeLabel(forCoordinate yValue: YAxisType, inViewPort viewPort: ViewPort) -> String
    
}

protocol HighlightInfoViewProvider {
    
    func provideHighlightInfoView(_ mode: ChartDisplayMode) -> UIView
    func updateHighlightInfoView(_ view: UIView, withHighlights highlights: [ChartData.Highlight])
    
    func updateHighlightInfoView(_ view: UIView, forMode: ChartDisplayMode)
    
}



class GraphPresenterParams {
    
    var xCoordinateLabler: IGraphCoordinateXLabeler?
    var yCoordinateLabler: IGraphCoordinateYLabeler?
    
    var highlightInfoViewProvider: HighlightInfoViewProvider?
    
    var showHighlights = false

}

extension GraphPresenterParams {

    var displayXAxis: Bool {
        return self.yCoordinateLabler != nil
    }

    var displayYAxis: Bool {
        return self.xCoordinateLabler != nil
    }

}


