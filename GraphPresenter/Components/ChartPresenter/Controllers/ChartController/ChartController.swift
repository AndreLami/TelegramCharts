//
//  GraphController.swift
//  ChartPresenter
//
//  Created by Andre on 3/12/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

private let TransitionAnimationDuration: TimeInterval = 0.3

final class ChartController: BaseGraphController {
    
    // Used for dynamic chart line width calculation
    var maxChartWidth: CGFloat = 1.0
    
    private var displayItemsManager: HighlightViewManager?
    
    private var highlightSurfaceAttcher: RendererAttacher<ICGSurfaceRenderer>!
    private var chartsSurfaceAttacher: RendererAttacher<IMetalSurfaceRenderer>!
    
    private var charts: [GraphData]? = nil
    private var currentRenderersMapToId = [String : MetalChartRenderer]()
    
    private var chartIdToHighlightRenderersMap = [String : ChartHighlightRender]()
    private var highlightSeparatorRender: ChartHighlightSeparatorRender? = nil
    
    private var highlights: [ChartData.Highlight]? = nil
    private var approximateHighlights: [ChartData.Highlight]? = nil
    
    private var displayModeApplyAnimationCancelation: RenderAnimator.AnimationCancelation? = nil
    
    private var chartLineWidth: CGFloat {
        return 2.0 - self.currentViewPort!.width / self.maxChartWidth
    }
    
    func updateGraphData(charts: [ChartData]?) {
        self.charts = charts
        self.onChartsUpdated(newCharts: charts)
        self.updateApproximateHighlights()
    }
    
    override func onReady() {
        
        let chartsSurfaceParams = MetalSurfaceParams.init(identifier: "ChartsSurface",
                                                          vertexFunction: "vertexShader",
                                                          fragmentFunction: "fragmentShader")
        self.chartsSurfaceAttacher = self.renderEnvironment?.createRenderSurface(withParams: chartsSurfaceParams)

        let levelsSurfaceParams = CGSurfaceParams.init(identifier: "LevelsSurface")
        self.highlightSurfaceAttcher = self.renderEnvironment?.createRenderSurface(withParams: levelsSurfaceParams)

        self.displayItemsManager = HighlightViewManager.init(withController: self)
        let itemsSurfaceParams = ViewSurfaceParams.init(identifier: "ItemsSurface")
        let itemsSurfaceAttcher = self.renderEnvironment?.createRenderSurface(withParams: itemsSurfaceParams)
        itemsSurfaceAttcher?.addRenderer(self.displayItemsManager!)
    }
    
    private func onChartsUpdated(newCharts: [ChartData]?) {
        if newCharts != nil {
            
            var disappearedGraphIds = Set<String>(self.currentRenderersMapToId.keys)
            
            newCharts?.forEach({ (graphData) in
                
                disappearedGraphIds.remove(graphData.id)
                
                var renderer = self.currentRenderersMapToId[graphData.id]
                
                if renderer == nil {
                    
                    renderer = MetalChartRenderer.init()
                    self.currentRenderersMapToId[graphData.id] = renderer
                    self.chartsSurfaceAttacher.addRenderer(renderer!)
                    
                    
                    renderer!.alpha = 0.0
                    renderer?.lineWidth = self.chartLineWidth
                    renderer!.displayParams = self.currentDisplayParams
                    
                    _ = self.renderEnvironment!.animate(duration: 0.3, updateBlock: { (percent, time) in
                        renderer!.alpha = 1.0 * percent
                    }, complitionBlock: { _ in
                    })
                    
                }
                
                renderer!.updateChart(chart: graphData)
            })
            
            for disappearedGraphId in disappearedGraphIds {
                
                if let renderer = self.currentRenderersMapToId[disappearedGraphId] {
                    
                    self.currentRenderersMapToId.removeValue(forKey: disappearedGraphId)
                    _ = self.renderEnvironment!.animate(duration: 0.3, updateBlock: { (percent, time) in
                        renderer.alpha = 1.0 - percent
                    }, complitionBlock: { _ in
                        self.chartsSurfaceAttacher.removeRenderer(renderer)
                    })
                }
            }

        }
        
        self.renderEnvironment?.setNeedsRerender()
    }
    
    override func onViewPortTransition(fromViewPort from: ViewPort, toViewPort: ViewPort) {
        self.displayItemsManager?.targetViewPort = toViewPort
    }
    
    override func onViewPortUpdated(_ viewPort: ViewPort) {
        if let visibleHiglight = self.highlights?.first {
            if visibleHiglight.point.coordinate.x < viewPort.x || visibleHiglight.point.coordinate.x > viewPort.xEnd {
                self.highlights = []
                self.updateApproximateHighlights()
            }
        }
        
        self.currentRenderersMapToId.values.forEach { (renderer) in
            renderer.lineWidth = self.chartLineWidth
        }
    }
    
    override func applyDisplayParams(_ oldDisplayParams: ChartDisplayParams?, newDisplayParams: ChartDisplayParams, animated: Bool) {
        
        self.displayModeApplyAnimationCancelation = nil
        self.displayModeApplyAnimationCancelation?.cancel()
        
        // Update info view
        
        self.displayItemsManager?.updateDisplayMode(self.currentDisplayMode, animated: animated)
        
        // Update renderers
        
        let higlightRenderers = self.chartIdToHighlightRenderersMap.values
        let separatorRenderer = self.highlightSeparatorRender
        
        if higlightRenderers.isEmpty && separatorRenderer == nil {
            return
        }
        
        
        if animated && oldDisplayParams != nil {
            
            let oldBackground = oldDisplayParams!.primaryBackgroundColor
            let newBackground = newDisplayParams.primaryBackgroundColor
            
            let oldAxisColor = oldDisplayParams!.primaryAxisColor
            let newAxisColor = newDisplayParams.primaryAxisColor
            
            
            
            
            let cancelation = self.renderEnvironment!.animate(duration: ChartDisplayModeAnimationDuration,
                                                              updateBlock: { (progress, elapsed) in
            
                let currentBackgroundColor = UIColor.transition(fromColor: oldBackground, toColor: newBackground, progress: progress) ?? newBackground
                let currentAxisColor = UIColor.transition(fromColor: oldAxisColor, toColor: newAxisColor, progress: progress) ?? newAxisColor
                
                for higlightRenderer in higlightRenderers {
                    higlightRenderer.fillColor = currentBackgroundColor
                }
                
                
                separatorRenderer?.strokeColor = currentAxisColor
                                                                
            }) { _ in }
            
            self.displayModeApplyAnimationCancelation = cancelation
        } else {
            let newBackground = newDisplayParams.primaryBackgroundColor
            let newAxisColor = newDisplayParams.primaryAxisColor
            
            for higlightRenderer in higlightRenderers {
                higlightRenderer.fillColor = newBackground
            }
            
            separatorRenderer?.strokeColor = newAxisColor
        }
    }
    
}

extension ChartController {
    
    func updateHighlights(_ highlights: [ChartData.Highlight]) {
        self.highlights = highlights
        self.updateApproximateHighlights()
    }
    
}

private extension ChartController {
    
    // Highlight come from original data, but we can get sparsed data. Figure out
    // highlights in sparsed data
    func updateApproximateHighlights() {
        
        guard let charts = self.charts, let highlights = self.highlights else {
            self.approximateHighlights = nil
            self.onHighlightsUpdated()
            
            return
        }
        
        var approximateHighlights = [ChartData.Highlight]()
        for highlight in highlights {
            let index = charts.firstIndex { (chart) -> Bool in
                return chart.id == highlight.chartId
            }
            
            if index == nil {
                continue
            }
            
            let chart = charts[index!]
            let neighbours = chart.findNeighbourPoints(forCoordinate: highlight.point.coordinate)
            
            guard let leftNeighbour = neighbours?.left, let rightNeighbour = neighbours?.right else {
                continue
            }
            
            // If this is the same point, use the same highligh
            if highlight.point.coordinate.x == leftNeighbour.coordinate.x ||
               highlight.point.coordinate.y == leftNeighbour.coordinate.y {
                approximateHighlights.append(highlight)
            } else {
                
                let x = highlight.point.coordinate.x
                let y = MathUtils.solveLinear(p1: leftNeighbour.coordinate, p2: rightNeighbour.coordinate, x: highlight.point.coordinate.x)
                
                let coordinate = ChartData.ChartCoordinate.init(x: x, y: y)
                let point = ChartData.Point.init(coordinate: coordinate,
                                                 originalData: highlight.point.originalData,
                                                 display: highlight.point.display)
                let approximateHighlight = ChartData.Highlight.init(withChartId: highlight.chartId, point: point, andDisplay: highlight.display)
                approximateHighlights.append(approximateHighlight)
                
            }
        }
        
        self.approximateHighlights = approximateHighlights
        self.onHighlightsUpdated()
    }
    
    func onHighlightsUpdated() {
        let highlights = self.approximateHighlights ?? []
        
        self.displayItemsManager?.updateHighlights(highlights: highlights)
        
        if highlights.isEmpty {
            
            if self.highlightSeparatorRender != nil {
                let renderer = self.highlightSeparatorRender
                self.highlightSeparatorRender = nil
                self.renderEnvironment!.animate(duration: TransitionAnimationDuration, updateBlock: { (progress, elapsed) in
                    renderer?.alpha = 1.0 - progress
                }) { (finished) in
                    self.highlightSurfaceAttcher.removeRenderer(renderer!)
                }
            }
            
        } else {
            if self.highlightSeparatorRender == nil {
                let renderer = ChartHighlightSeparatorRender()
                
                renderer.strokeColor = self.currentDisplayParams.primaryAxisColor
                
                self.highlightSeparatorRender = renderer
                renderer.alpha = 0
                self.renderEnvironment!.animate(duration: TransitionAnimationDuration, updateBlock: { (progress, elapsed) in
                    renderer.alpha = progress
                }) { _ in }
                
                self.highlightSurfaceAttcher.addRenderer(self.highlightSeparatorRender!)
            }
            
            self.highlightSeparatorRender?.highlight = highlights.first!.point
            
            
        }
        
        var renderersToRemove = Set<String>(self.chartIdToHighlightRenderersMap.keys)
        for highlight in highlights {
            renderersToRemove.remove(highlight.chartId)
            
            var renderer = self.chartIdToHighlightRenderersMap[highlight.chartId]
            if renderer == nil {
                renderer = ChartHighlightRender()
                
                renderer!.alpha = 0
                renderer!.fillColor = self.currentDisplayParams.primaryBackgroundColor
                self.chartIdToHighlightRenderersMap[highlight.chartId] = renderer!
                self.highlightSurfaceAttcher.addRenderer(renderer!)
                
                self.renderEnvironment!.animate(duration: TransitionAnimationDuration, updateBlock: { (progress, elapsed) in
                    renderer!.alpha = progress
                }, complitionBlock: { _ in })
            }
            
            renderer?.highlight = highlight
        }
        
        for rendererId in renderersToRemove {
            let renderer = self.chartIdToHighlightRenderersMap[rendererId]
            self.chartIdToHighlightRenderersMap.removeValue(forKey: rendererId)
            
            self.renderEnvironment!.animate(duration: TransitionAnimationDuration, updateBlock: { (progress, elapsed) in
                renderer!.alpha = (1.0 - progress)
            }, complitionBlock: { _ in
                self.highlightSurfaceAttcher.removeRenderer(renderer!)
            })
        }
        
        self.renderEnvironment?.setNeedsRerender()
       
    }
    
    
    
}

private final class HighlightViewManager: BaseViewSerfaceRenderer {
    
    fileprivate final class HighlightInfoItem {
        
        var offset: RenderAnimatableValue<CGFloat>
        var view: UIView?
        var highlights: [ChartData.Highlight]?
        var position: XAxisType = 0
        
        var isInitiallyLayedOut: Bool = false
        
        var dismissPin: CGPoint?
        
        init(offset: RenderAnimatableValue<CGFloat>) {
            self.offset = offset
        }
        
    }
    
    private weak var controller: ChartController!
    var targetViewPort: ViewPort?
    
    private var renderEnvironment: IRenderEnvironment {
        return self.controller.renderEnvironment!
    }
    
    init(withController controller: ChartController) {
        self.controller = controller
        super.init()
        self.zIndex = 25
    }
    
    private var highlightInfoItem: HighlightInfoItem? = nil
    
    private var highlights: [ChartData.Highlight]?
    private var currentHighlightPosition: XAxisType?
    
    func updateDisplayMode(_ mode: String, animated: Bool) {
        if self.highlightInfoItem != nil {
            self.controller.graphParams.highlightInfoViewProvider?.updateHighlightInfoView(self.highlightInfoItem!.view!,
                                                                                           forMode: mode,
                                                                                           animated: animated)
        }
    }
    
    func updateHighlights(highlights: [ChartData.Highlight]) {
        
        let currentHighlightPosition = self.highlights?.first?.point.coordinate.x
        let nextHighlightPosition = highlights.first?.point.coordinate.x
        
        self.highlights = highlights
        
        
        if highlights.isEmpty {
            self.currentHighlightPosition = nil
            
            if let view = self.highlightInfoItem?.view {
                // Will pin the view on dissmiss (by generating constraints)
                view.translatesAutoresizingMaskIntoConstraints = true
                
                
                UIView.animate(withDuration: TransitionAnimationDuration, animations: {
                    view.alpha = 0
                }) { _ in
                    view.removeFromSuperview()
                }
            }
        
            
            self.highlightInfoItem = nil
        } else {
            
            if self.highlightInfoItem == nil {
                self.highlightInfoItem = self.createHighlightItemIfNeeded(highlights: highlights)
                self.container?.addSubview(self.highlightInfoItem!.view!)
                self.highlightInfoItem!.view!.alpha = 0
                
                UIView.animate(withDuration: TransitionAnimationDuration, animations: {
                    self.highlightInfoItem!.view!.alpha = 1
                })
            }
            
            self.controller.graphParams.highlightInfoViewProvider?.updateHighlightInfoView(self.highlightInfoItem!.view!,
                                                                                           withHighlights: highlights)
            
            self.highlightInfoItem!.highlights = highlights
            
            let isNewTransition = currentHighlightPosition != nextHighlightPosition
            if isNewTransition {
                self.highlightInfoItem!.offset.updateValue(newValue: 0, animated: false)
                self.highlightInfoItem?.isInitiallyLayedOut = false
            }
            self.highlightInfoItem?.position = nextHighlightPosition!
            self.currentHighlightPosition = nextHighlightPosition
        }
        
        container?.setNeedsLayout()
    }
    
    func createHighlightItemIfNeeded(highlights: [ChartData.Highlight]) -> HighlightInfoItem {
        
        let offset = self.renderEnvironment.createAnimatableValue(initialValue: 0.0,
                                                                  animationStrategy: RenderAnimatableValue.AnimationStrategy.StartNew) { (from, to, progress) -> CGFloat? in
                                                                    return from! + (to! - from!) * progress
        }
        
        offset.easingFunction = RenderEasingUtils.quadraticEaseIn
        offset.defaultAnimationDuration = 0.15
        
        let highlightInfoItem = HighlightInfoItem.init(offset: offset)
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 50))
        view.backgroundColor = UIColor.red
        
        highlightInfoItem.view = self.controller.graphParams.highlightInfoViewProvider?.provideHighlightInfoView(self.controller.currentDisplayMode)
        
        
        return highlightInfoItem
    }
    
    override func onAttached() {
        self.container!.clipsToBounds = true
    }
    
    override func layout(viewPort: ViewPort, dimensionsConverter: DimensionsConverter) {
        
        guard let displayItem = self.highlightInfoItem, let view = displayItem.view else {
            return
        }
        
        let minVerticalOffsetToItem: CGFloat = 5
        let minHorizontalOffsetToItem: CGFloat = 5
        
        let itemTopOffset: YAxisType = YAxisType(10)
        
        let viewPortToUse = self.targetViewPort ?? viewPort
        
        let containerBounds = self.container!.bounds
        
        let desiredChartCoordinate = ChartData.ChartCoordinate.init(x: displayItem.position, y: viewPort.yEnd - itemTopOffset)
        let desiredDisplayPoint = dimensionsConverter.convertGraphPointToDisplayPoint(viewPort: viewPort, graphPoint: desiredChartCoordinate)

        let desiredXCenter = desiredDisplayPoint.x
        let desiredYCenter = desiredDisplayPoint.y + view.bounds.height / 2
        
        var currentXCenter = desiredXCenter + displayItem.offset.currentValue! * view.bounds.width / 2
        
        view.center = CGPoint.init(x: currentXCenter, y: desiredYCenter)
        let currentFrame = view.frame
        
        view.center = CGPoint.init(x: desiredXCenter, y: desiredYCenter)
        let desiredFrame = view.frame

        var intersectsHighlights = false
        for highlight in displayItem.highlights! {

            let highlightDisplayPoint = dimensionsConverter.convertGraphPointToDisplayPoint(viewPort: viewPortToUse, graphPoint: highlight.point.coordinate)
            if desiredFrame.maxY >= highlightDisplayPoint.y - minVerticalOffsetToItem {
                intersectsHighlights = true
                break
            }

        }
        
        // We have 2 cases
        // 1. View intersects highlight. If so, then we should deside which side to put view on.
        //    We put it on the right side in case we intersect left bound. If view intersects left bound,
        //    we put it on the right side. Otherwise we select side based on mid point.
        // 2. We do not intersect highlight. Then we update offset to 0 to center highlight view.
        //
        // The last step is to adjust current currentXCenter to prevent container intersection

        let animated = displayItem.isInitiallyLayedOut == true
        if intersectsHighlights {
            let maxX = desiredXCenter + view.bounds.width
            let minX = desiredXCenter - view.bounds.width

            // Select side
            
            let moveRight: CGFloat = -1.2
            let moveLeft: CGFloat = 1.2
            
            let side: CGFloat
            if maxX >= containerBounds.maxX - minHorizontalOffsetToItem {
                side = moveRight
            } else if minX <= containerBounds.minX + minHorizontalOffsetToItem {
                side = moveLeft
            } else {

                if displayItem.offset.targetValue == 0.0 {
                    if desiredXCenter > containerBounds.midX {
                        side = moveRight
                    } else {
                        side = moveLeft
                    }
                } else {
                   side = displayItem.offset.targetValue!
                }
            }

            if displayItem.offset.targetValue != side {
                displayItem.offset.updateValue(newValue: side, animated: animated)
            }

            if animated == false {
                currentXCenter = desiredXCenter + displayItem.offset.currentValue! * view.bounds.width / 2
            }
        } else {
            if displayItem.offset.targetValue != 0 {
                displayItem.offset.updateValue(newValue: 0, animated: animated)
            }
        }

        // We should never intersect bounds, So adjust current x
        let xOffset: CGFloat
        if currentFrame.minX < containerBounds.minX {
            xOffset = containerBounds.minX - currentFrame.minX
        } else if currentFrame.maxX > containerBounds.maxX {
            xOffset = containerBounds.maxX - currentFrame.maxX
        } else {
            xOffset = 0
        }

        currentXCenter += xOffset



        displayItem.isInitiallyLayedOut = true
        view.center = CGPoint.init(x: currentXCenter, y: desiredYCenter)
    }
    
    
    
}
