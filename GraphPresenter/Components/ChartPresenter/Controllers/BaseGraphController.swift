//
//  BaseChartController.swift
//  ChartPresenter
//
//  Created by Andre on 3/15/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation


class BaseGraphController: IRenderController {
    
    let graphParams: ChartPresenterParams
    private (set) var currentDisplayMode: String
    
    private (set) var currentDisplayParams: ChartDisplayParams
    
    private (set) var renderEnvironment: IRenderEnvironment?
    
    init(withParams params: ChartPresenterParams, andDisplayMode mode: String) {
        self.graphParams = params
        self.currentDisplayMode = mode
        self.currentDisplayParams = params.displayParams(forMode: mode)
    }
    
    var currentViewPort: ViewPort? {
        return self.renderEnvironment?.viewPort
    }
    
    var dimensionsConverter: DimensionsConverter? {
        return self.renderEnvironment?.dimensionsConverter
    }
    
    func updateDisplayMode(withMode mode: String, animated: Bool) {
        if self.currentDisplayMode == mode {
            return
        }
        
        let oldParams = self.currentDisplayParams
        self.currentDisplayMode = mode
        self.currentDisplayParams = self.graphParams.displayParams(forMode: mode)
        self.applyDisplayParams(oldParams, newDisplayParams: self.currentDisplayParams, animated: animated)
    }
    
    // Methods to override
    
    func onReady() {}
    
    func attachToRenderEnvironment(_ renderEnvironment: IRenderEnvironment) {
        self.renderEnvironment = renderEnvironment
        self.onReady()
    }
    
    func cleanup() {}
    
    func onViewPortTransition(fromViewPort from: ViewPort, toViewPort: ViewPort) {}
    
    func onViewPortUpdated(_ viewPort: ViewPort) {}
    
    func applyDisplayParams(_ oldDisplayParams: ChartDisplayParams?, newDisplayParams: ChartDisplayParams, animated: Bool) {
        
    }
    
}
