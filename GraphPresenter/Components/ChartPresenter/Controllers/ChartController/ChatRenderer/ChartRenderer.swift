//
//  ChartRenderer.swift
//  ChartPresenter
//
//  Created by Andre on 3/10/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit


class ChartRenderer: ICGSurfaceRenderer {
    
    var zIndex: Int = 10
    
    var graph: GraphData? = nil
    
    var alpha: CGFloat = 0.0
    
    var displayParams: ChartDisplayParams?
    
    var lineWidth: CGFloat?
    
    func render(withContext context: RenderingContext) {
        
        guard let graph = self.graph, let displayParams = self.displayParams  else {
            return
        }
        
        self.render(graph: graph, withContext: context, displayParams: displayParams)
        
    }
    
    private func render(graph: GraphData, withContext renderContext: RenderingContext, displayParams: ChartDisplayParams) {
        
        if graph.points.count < 1
        {
            return
        }
        
        let dimConverter = renderContext.dimensionsConverter
        let viewPort = renderContext.viewPort
        
        let context = renderContext.drawContext
        
        context.saveGState()
        
        context.setAlpha(self.alpha)
        let lineWidth = self.lineWidth ?? 1.0
        context.setLineWidth(lineWidth)
        
        let strokeColor = graph.display?.color?.cgColor ?? UIColor.black.cgColor
        context.setStrokeColor(strokeColor)
        
        let firstPoint = graph.points[0].coordinate
        let firstDisplayPoint = dimConverter.convertGraphPointToDisplayPoint(viewPort: viewPort,
                                                                             graphPoint: firstPoint)
        
        context.move(to: firstDisplayPoint)
        
        for i in 1 ..< graph.points.count {
            let toPoint = graph.points[i].coordinate
            
            
            let toDisplayPoint = dimConverter.convertGraphPointToDisplayPoint(viewPort: viewPort,
                                                                                graphPoint: toPoint)
            
            context.addLine(to: toDisplayPoint)
        }
        
        context.strokePath()
        context.restoreGState()
    }
}

class ChartHighlightRender: ICGSurfaceRenderer {
    
    static let HighlightWidth: CGFloat = 6
    
    var zIndex: Int = 12
    
    var highlight: GraphData.Highlight? = nil
    
    var alpha: CGFloat = 0.0
    
    var strokeColor: UIColor?
    var fillColor: UIColor?
    
    func render(withContext context: RenderingContext) {
        
        guard let highlight = self.highlight else {
            return
        }
        
        self.render(highlight: highlight, withContext: context)
        
    }
    
    private func render(highlight: GraphData.Highlight, withContext renderContext: RenderingContext) {
        
        
        let context = renderContext.drawContext
        
        context.saveGState()
        
        let dimConverter = renderContext.dimensionsConverter
        let viewPort = renderContext.viewPort
        
        
        context.setLineWidth(2.0)
        
        let point = highlight.point
        
        let fillColor = self.fillColor ?? UIColor.black
        
        let strokeColor = highlight.display?.color?.cgColor ?? UIColor.black.cgColor
        
        let displayPoint = dimConverter.convertGraphPointToDisplayPoint(viewPort: viewPort,
                                                                        graphPoint: point.coordinate)
        
        
        let rect = CGRect.init(x: displayPoint.x - ChartHighlightRender.HighlightWidth / 2.0, y: displayPoint.y - ChartHighlightRender.HighlightWidth / 2.0, width: ChartHighlightRender.HighlightWidth, height: ChartHighlightRender.HighlightWidth)
        
        context.setStrokeColor(strokeColor)
        context.setFillColor(fillColor.cgColor)
        context.setAlpha(self.alpha)
        context.fillEllipse(in: rect)
        context.strokeEllipse(in: rect)
        
        context.restoreGState()
    }
    
}

class ChartHighlightSeparatorRender: ICGSurfaceRenderer {
    
    var zIndex: Int = 9
    
    var highlight: GraphData.Point? = nil
    
    var alpha: CGFloat = 0.0
    
    var strokeColor: UIColor?
    
    func render(withContext context: RenderingContext) {
        
        guard let highlight = self.highlight else {
            return
        }
        
        self.render(highlight: highlight, withContext: context)
        
    }
    
    private func render(highlight: GraphData.Point, withContext renderContext: RenderingContext) {
        
        let context = renderContext.drawContext
        
        context.saveGState()
        
        let dimConverter = renderContext.dimensionsConverter
        let viewPort = renderContext.viewPort
        
        context.setAlpha(self.alpha)
        context.setLineWidth(1.0)
        
        let strokeColor = self.strokeColor?.cgColor ?? UIColor.black.cgColor
        
        let startCoordinate = ChartData.ChartCoordinate.init(x: highlight.coordinate.x, y: viewPort.y)
        let endCoordinate = ChartData.ChartCoordinate.init(x: highlight.coordinate.x, y: viewPort.yEnd)
        
        let startDisplayPoint = dimConverter.convertGraphPointToDisplayPoint(viewPort: viewPort,
                                                                             graphPoint: startCoordinate)
        
        let endDisplayPoint = dimConverter.convertGraphPointToDisplayPoint(viewPort: viewPort,
                                                                           graphPoint: endCoordinate)
        
        
        context.setStrokeColor(strokeColor)
        
        context.setAlpha(self.alpha)
        context.setLineWidth(0.5)
        
        context.move(to: CGPoint(x: startDisplayPoint.x, y: startDisplayPoint.y))
        context.addLine(to: CGPoint(x: endDisplayPoint.x, y: endDisplayPoint.y))
        
        context.strokePath()
        context.restoreGState()
    }
    
}
