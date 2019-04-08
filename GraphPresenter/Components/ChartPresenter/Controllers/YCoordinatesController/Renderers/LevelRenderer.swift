//
//  YRowsRenderer.swift
//  ChartPresenter
//
//  Created by Andre on 3/15/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

class LevelRenderer: ICGSurfaceRenderer {
    
    var zIndex: Int = 1
    
    var rowColor: UIColor?
    var rowWidth: CGFloat?
    var rowAlpha: CGFloat?
    
    class Row {
        let level: YAxisType
        
        init(withLevel level: YAxisType) {
            self.level = level
        }
    }
    
    var levels = [Row]()
    
    func updateLevels(_ levels: [Row]) {
        self.levels = levels
    }

    func render(withContext context: RenderingContext) {
        self.render(levels: self.levels, withContext: context)
    }
    
    private func render(levels: [Row], withContext renderContext: RenderingContext) {
        if levels.isEmpty {
            return
        }
        
        let context = renderContext.drawContext
        let viewPort = renderContext.viewPort
        
        context.saveGState()
        
        let rowAlpha = self.rowAlpha ?? 1.0
        let rowWidth = self.rowWidth ?? 1.0
        let rowColor = self.rowColor ?? UIColor.black
        
        context.setAlpha(rowAlpha)
        context.setLineWidth(rowWidth)
        
        let strokeColor = rowColor.cgColor
        context.setStrokeColor(strokeColor)
        
        var segments: [CGPoint] = []
        
        let dimConverter = renderContext.dimensionsConverter
        
        for level in levels {
            
            let fromPoint = GraphData.GraphCoordinate.init(x: viewPort.x, y: level.level)
            let toPoint = GraphData.GraphCoordinate.init(x: viewPort.xEnd, y: level.level)
            
            let fromDisplayPoint = dimConverter.convertGraphPointToDisplayPoint(viewPort: viewPort,
                                                                                graphPoint: fromPoint)
            
            let toDisplayPoint = dimConverter.convertGraphPointToDisplayPoint(viewPort: viewPort,
                                                                              graphPoint: toPoint)
            
            segments.append(fromDisplayPoint)
            segments.append(toDisplayPoint)
        }
        
        context.strokeLineSegments(between: segments)
        
        context.restoreGState()
    }
}
