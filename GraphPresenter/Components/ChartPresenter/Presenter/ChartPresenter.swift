//
//  ChartPresenter.swift
//  ChartPresenter
//
//  Created by Andre on 3/10/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit


let ChartDisplayModeAnimationDuration = 0.3

final class ChartPresenter {
    
    private let params: ChartPresenterParams
    private let renderStage: RenderStage
    
    private var currentDisplayMode: String
    
    var currentViewPort: ViewPort {
        return self.renderStage.currentViewPort
    }
    
    private var yCoordinatesController: YCoordinatesController?
    private var xCoordinatesController: XCoordinatesController?
    
    private var emptyController: EmptyController!
    
    private var chartController: ChartController!
    
    private var dataProvider: IChartsDataProvider? = nil
    
    private var reloadDataTask: ALTask?
    
    private var allControllers = [BaseGraphController]()
    
    init(withViewPort viewPort: ViewPort, andParams params: ChartPresenterParams) {
        self.renderStage = RenderStage.init(viewPort: viewPort)
        self.params = params
        self.currentDisplayMode = params.initialDisplayMode
        
        self.setup()
    }
    
}


extension ChartPresenter {
    
    var mainView: UIView {
        return self.renderStage.mainView
    }
    
}

extension ChartPresenter {
    
    func reloadData() {
        self.doReloadData()
    }
    
    func updateDataProvider(_ dataProvider: IChartsDataProvider) {
        self.dataProvider = dataProvider
        
        self.chartController.maxChartWidth = self.dataProvider!.maxX - self.dataProvider!.minX
        self.reloadData()
    }
    
    func updateViewPort(_ viewPortUpdate: ViewPort.Update, animated: Bool) {
        self.renderStage.updateViewPort(viewPortUpdate, animated: animated)
        self.reloadData()
    }
    
    func updateViewPort(_ viewPort: ViewPort, animated: Bool) {
        self.renderStage.updateViewPort(viewPort.update().update(yEnd: nil), animated: animated)
        self.reloadData()
    }
    

    func updateMode(mode: String, animated: Bool = false) {
        if self.currentDisplayMode == mode {
            return
        }
        
        self.currentDisplayMode = mode
        
        self.allControllers.forEach { (controller) in
            controller.updateDisplayMode(withMode: mode, animated: animated)
        }

    }

}

private extension ChartPresenter {
    
    func setup() {
        self.setupControllers()
        self.setupInteractions()
    }
    
    private func setupControllers() {
        let topOffset: CGFloat = 10
        var botOffset: CGFloat = 0
        

        if (self.params.displayYAxis) {
            self.yCoordinatesController = YCoordinatesController.init(withParams: self.params, andDisplayMode: self.currentDisplayMode)
            self.renderStage.addRendererController(self.yCoordinatesController!, forRenderTargetwithParams: RenderTargetParams.init(withIdentifier: "Coordinates"))


            botOffset = 30
            self.allControllers.append(self.yCoordinatesController!)

        }

        if (self.params.displayXAxis) {
            self.xCoordinatesController = XCoordinatesController.init(withParams: self.params, andDisplayMode: self.currentDisplayMode)
            self.renderStage.addRendererController(self.xCoordinatesController!, forRenderTargetwithParams: RenderTargetParams.init(withIdentifier: "Coordinates"))

            botOffset = 30
            self.allControllers.append(self.xCoordinatesController!)
        }
        
        self.chartController = ChartController.init(withParams: self.params, andDisplayMode: self.currentDisplayMode)
        let p = RenderTargetParams.init(withIdentifier: "Chart")
        p.type = "metal"
        self.renderStage.addRendererController(self.chartController, forRenderTargetwithParams: p)

        self.emptyController = EmptyController.init(withParams: self.params, andDisplayMode: self.currentDisplayMode)
        self.renderStage.addRendererController(self.emptyController, forRenderTargetwithParams: RenderTargetParams.init(withIdentifier: "Empty"))
        
        self.allControllers.append(self.emptyController)
        self.allControllers.append(self.chartController)
        
        self.renderStage.renderOffset = UIEdgeInsets.init(top: topOffset, left: 0, bottom: botOffset, right: 0)
        
        self.renderStage.mainView.backgroundColor = UIColor.clear
    }
    
    private func setupInteractions() {
        if self.params.showHighlights {
            let highlightPointInteraction = UITapGestureRecognizer.init(target: self, action: #selector(pickHighlightPoint(_:)))
            self.renderStage.addInteraction(interraction: highlightPointInteraction)
            
            let clearHighlightsInteractionSwitpeLeft = UISwipeGestureRecognizer.init(target: self, action: #selector(clearHighlights(_:)))
            clearHighlightsInteractionSwitpeLeft.direction = .left
            let clearHighlightsInteractionSwipeRight = UISwipeGestureRecognizer.init(target: self, action: #selector(clearHighlights(_:)))
            clearHighlightsInteractionSwipeRight.direction = .right
            self.renderStage.addInteraction(interraction: clearHighlightsInteractionSwitpeLeft)
            self.renderStage.addInteraction(interraction: clearHighlightsInteractionSwipeRight)
        }
    }
    
}

private extension ChartPresenter {
    
    @objc func pickHighlightPoint(_ interaction: UIGestureRecognizer) {
        guard let dataProvider = self.dataProvider else {
            return
        }
        let displayPoint = interaction.location(in: interaction.view!)
        let chartCoordinate = self.renderStage.convert(displayPoint: displayPoint)
        
        var highlights = [ChartData.Highlight]()
        
        // Chart can appear and go away, so we calculate highlights for all charts
        // Controller should filter them out
        for chart in dataProvider.allCharts {
            if let closestPoint = chart.findClosestPoint(forCoordinate: chartCoordinate) {
                
                let display = ChartData.HighlightDisplay.init(withColor: chart.display?.color)
                
                let highlight = ChartData.Highlight.init(withChartId: chart.id, point: closestPoint, andDisplay: display)
                
                highlights.append(highlight)
            }
        }
        
        self.chartController.updateHighlights(highlights)
    }
    
    @objc func clearHighlights(_ interaction: UIGestureRecognizer) {
        if interaction.state == UIGestureRecognizer.State.recognized {
            self.chartController.updateHighlights([])
        }
    }
}

private extension ChartPresenter {
    
    func doReloadData() {
        self.reloadDataTask?.cancel()
        self.reloadDataTask = nil
        
        self.reloadDataTask = self.dataProvider?.provideChartsData(forViewPort: self.currentViewPort).then { (result) -> Void in
            let charts = result as! [ChartData]
            
            self.chartController.updateGraphData(charts: charts)
            self.emptyController.updateForGraphData(charts)
            
            self.renderStage.setNeedsRerender()
            self.adjustViewPort(forCharts: charts)
        }
        
    }
    
    func adjustViewPort(forCharts charts: [GraphData]) {
        if charts.isEmpty {
            return
        }
        
        var currentMaxY = self.currentViewPort.yEnd
        
        let maxChartY = charts.reduce(YAxisType.minVal) { (current, chart) -> YAxisType in
            return max(current, chart.maxY)
        }

        if maxChartY <= 0 {
            return
        }

        // To avoid jups for y coord animation, we basically
        // add extra to the top of the max coord. Also we downgrade
        // with extra offset. Values are selected empirically.
        let topOffsetExtra: YAxisType =  maxChartY * 0.05
        var shouldChange = false
        if maxChartY > currentMaxY {
            currentMaxY = maxChartY + topOffsetExtra
            shouldChange = true
        } else if (currentMaxY - maxChartY) > currentMaxY * 0.1  {
            currentMaxY = maxChartY + topOffsetExtra
            shouldChange = true
        }

        if shouldChange {
            let update = ViewPort.update().update(yEnd: currentMaxY).update(y: 0)
            self.renderStage.updateViewPort(update, animated: true)
        }
    }
    
}

