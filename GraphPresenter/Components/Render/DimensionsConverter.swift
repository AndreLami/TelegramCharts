//
//  GraphDimensionsConverter.swift
//  ChartPresenter
//
//  Created by Andre on 3/10/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

@objc class DimensionsConverter: NSObject {
    
    var offset: UIEdgeInsets = UIEdgeInsets.init()
    
    private let view: UIView
    
    init(view: UIView) {
        self.view = view
    }
    
    func convertDisplayPointToGraphPoint(viewPort: ViewPort, displayPoint: CGPoint, offset inOffset: UIEdgeInsets? = nil) -> GraphData.GraphCoordinate {
        let offset: UIEdgeInsets
        if inOffset == nil {
            offset = self.offset
        } else {
            offset = inOffset!
        }
        
        let rawBounds = view.bounds
        let bounds = rawBounds.inset(by: offset)
    
        
        return self.convertDisplayPointToGraphPoint(viewPort: viewPort, displayRect: bounds, displayPoint: displayPoint)
    }
    
    private func convertDisplayPointToGraphPoint(viewPort: ViewPort, displayRect: CGRect, displayPoint: CGPoint) -> GraphData.GraphCoordinate {
        let bounds = displayRect
        
        let x = displayPoint.x - bounds.minX
        let y = (bounds.height - displayPoint.y + bounds.minY)
        let xScale = viewPort.width / bounds.width
        let yScale = viewPort.height / bounds.height
        
        let vpX = viewPort.x + x * xScale
        let vpY = viewPort.y + y * yScale
        
        if vpX.isNaN || vpY.isNaN {
            return GraphData.GraphCoordinate.init(x: 0, y: 0)
        }
        
        return GraphData.GraphCoordinate.init(x: vpX, y: vpY)
    }
    
    func convertGraphPointToDisplayPoint(viewPort: ViewPort, graphPoint: GraphData.GraphCoordinate, offset inOffset: UIEdgeInsets? = nil) -> CGPoint {
        let offset: UIEdgeInsets
        if inOffset == nil {
            offset = self.offset
        } else {
            offset = inOffset!
        }
        
        let rawBounds = view.bounds
        let bounds = rawBounds.inset(by: offset)
        
        return self.convertGraphPointToDisplayPoint(viewPort: viewPort, displayRect: bounds, graphPoint: graphPoint)
    }
    
    private func convertGraphPointToDisplayPoint(viewPort: ViewPort, displayRect: CGRect, graphPoint: GraphData.GraphCoordinate, offset inOffset: UIEdgeInsets? = nil) -> CGPoint {
        
        let bounds = displayRect
        
        let xScale = viewPort.width / bounds.width
        let yScale = viewPort.height / bounds.height
        
        let xBack = (graphPoint.x - viewPort.x) / xScale + bounds.minX
        let yBack = bounds.height + bounds.minY - (graphPoint.y - viewPort.y) / yScale
        
      
        if xBack.isNaN || yBack.isNaN {
            return CGPoint.init(x: 0, y: 0)
        }
        
        return CGPoint.init(x: xBack, y: yBack)
    }
    
    private func calculateViewPort(srcViewPort: ViewPort, srcScreen: CGRect, dstScreen: CGRect) -> ViewPort {
        let graphPoint1 = ChartData.ChartCoordinate.init(x: 100, y: 500)
        let graphPoint2 = ChartData.ChartCoordinate.init(x: 1000, y: 1000)
        
        
        let srcDisplayPoint1 = self.convertGraphPointToDisplayPoint(viewPort: srcViewPort, displayRect: srcScreen, graphPoint: graphPoint1)
        let srcDisplayPoint2 = self.convertGraphPointToDisplayPoint(viewPort: srcViewPort, displayRect: srcScreen, graphPoint: graphPoint2)
        
        let dstDisplayPoint1 = srcDisplayPoint1
        let dstDisplayPoint2 = srcDisplayPoint2
        
        let k1 = (dstDisplayPoint1.y - dstScreen.height - dstScreen.minY)
        let k2 = (dstDisplayPoint2.y - dstScreen.height - dstScreen.minY)
        
        // TODO: Keep in mind devision by 0
        let c = k2 / k1
        let viewPortY = (c * dstScreen.height * graphPoint1.y - dstScreen.height * graphPoint2.y) / (c * (k1 + dstScreen.height) - (k2 + dstScreen.height))
        let viewPortYEnd = (viewPortY * (k1 + dstScreen.height) - dstScreen.height * graphPoint1.y) / k1
        
        let resultVP = ViewPort.init(x: srcViewPort.x, y: viewPortY, xEnd: srcViewPort.xEnd, yEnd: viewPortYEnd)
        
        return resultVP
    }
    
    func convertViewPortToDisplayViewPort(_ viewPort: ViewPort) -> ViewPort {
        let srcScreen = self.view.bounds.inset(by: self.offset)
        let dstScreen = self.view.bounds
        
        return self.calculateViewPort(srcViewPort: viewPort, srcScreen: srcScreen, dstScreen: dstScreen)
    }
    
}
