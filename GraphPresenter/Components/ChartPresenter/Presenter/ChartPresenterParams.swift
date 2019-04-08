//
//  ChartPresenterOptions.swift
//  ChartPresenter
//
//  Created by Andre on 3/15/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

final class ChartPresenterParams {
    
    private var displayParamsRegistry = [String : ChartDisplayParams]()
    
    let initialDisplayMode: String
    
    var xCoordinateLabler: IGraphCoordinateXLabeler?
    var yCoordinateLabler: IGraphCoordinateYLabeler?
    
    var highlightInfoViewProvider: IHighlightInfoViewProvider?
    
    private var lineWidth: CGFloat = 1.0
    
    var showHighlights = false
    
    init(withInitialDisplayMode initialDisplayMode: String) {
        self.initialDisplayMode = initialDisplayMode
    }
    
    func addDisplayParams(_ params: ChartDisplayParams, forMode mode: String) {
        self.lineWidth = params.lineWidth
        self.displayParamsRegistry[mode] = params
    }
    
    func displayParams(forMode mode: String) -> ChartDisplayParams {
        let params = self.displayParamsRegistry[mode]
        if params == nil {
            print("Error: no display params for mode \(mode). Using default")
        }
        
        params?.lineWidth = self.lineWidth
        return params ?? ChartDisplayParams.defaultParams
    }
    
}

final class ChartDisplayParams {
    
    let primaryBackgroundColor: UIColor
    
    let primaryTextColor: UIColor
    
    let primaryAxisColor: UIColor
    let secondaryAxisColor: UIColor
    
    var lineWidth: CGFloat
    
    
    init(primaryBackgroundColor: UIColor,
         primaryTextColor: UIColor,
         primaryAxisColor: UIColor,
         secondaryAxisColor: UIColor,
         lineWidth: CGFloat) {
        
        self.primaryBackgroundColor = primaryBackgroundColor
        self.primaryTextColor = primaryTextColor
        self.primaryAxisColor = primaryAxisColor
        self.secondaryAxisColor = secondaryAxisColor
        self.lineWidth = lineWidth
    }
    
    static var defaultParams: ChartDisplayParams {
        let params = ChartDisplayParams.init(primaryBackgroundColor: UIColor.init(red: 239.0 / 255.0, green: 239.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0),
                                             primaryTextColor: UIColor.init(red: 109.0 / 255.0, green: 109.0 / 255.0, blue: 114.0 / 255.0, alpha: 1.0),
                                             primaryAxisColor: UIColor.init(red: 207.0 / 255.0, green: 209.0 / 255.0, blue: 210.0 / 255.0, alpha: 1.0),
                                             secondaryAxisColor: UIColor.init(red: 243.0 / 255.0, green: 243.0 / 255.0, blue: 243.0 / 255.0, alpha: 1.0),
                                             lineWidth: 1.0)
        
        return params
    }
    
}

protocol IGraphCoordinateXLabeler {
    
    func makeLabel(forCoordinate xValue: XAxisType, inViewPort viewPort: ViewPort) -> String
    
}

protocol IGraphCoordinateYLabeler {
    
    func makeLabel(forCoordinate yValue: YAxisType, inViewPort viewPort: ViewPort) -> String
    
}

protocol IHighlightInfoViewProvider {
    
    func provideHighlightInfoView(_ mode: String) -> UIView
    func updateHighlightInfoView(_ view: UIView, withHighlights highlights: [ChartData.Highlight])
    
    func updateHighlightInfoView(_ view: UIView, forMode mode: String, animated: Bool)
    
}


extension ChartPresenterParams {
    
    var displayXAxis: Bool {
        return self.yCoordinateLabler != nil
    }
    
    var displayYAxis: Bool {
        return self.xCoordinateLabler != nil
    }
    
}
