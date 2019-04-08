//
//  MetalChartRenderer.swift
//  GraphPresenter
//
//  Created by Andre on 3/27/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import MetalKit

class MetalChartRenderer: IMetalSurfaceRenderer {
    
    
    func setupWithView(_ view: MTKView) {
        let device = view.device!
        
        let totalSpriteVertexCount = 400;
        let totalIndexCount = totalSpriteVertexCount * 6;
        
        let spriteVertexBufferSize = totalSpriteVertexCount * MemoryLayout<ChartRenderVertex>.stride
        let spriteIndexBufferSize = totalIndexCount * MemoryLayout<UInt16>.size
        
        self.vertexBuffer = device.makeBuffer(length: spriteVertexBufferSize, options: MTLResourceOptions.cpuCacheModeWriteCombined)!
        let vb = self.vertexBuffer.contents().bindMemory(to: ChartRenderVertex.self, capacity: totalSpriteVertexCount)
        vb.initialize(repeating: ChartRenderVertex(), count: totalSpriteVertexCount)
        
        self.indexBuffer = device.makeBuffer(length: spriteIndexBufferSize, options: MTLResourceOptions.cpuCacheModeWriteCombined)!
        let ib = self.indexBuffer.contents().bindMemory(to: UInt16.self, capacity: totalIndexCount)
        ib.initialize(repeating: UInt16(0), count: totalIndexCount)
    }
    
    var graph: GraphData? = nil
    
    var alpha: CGFloat = 0.0
    
    var displayParams: ChartDisplayParams?
    
    var lineWidth: CGFloat?
    
    
    
    private var chart: ChartData?
    
    private var vertexBuffer: MTLBuffer!
    private var indexBuffer: MTLBuffer!
    
    func updateChart(chart: ChartData) {
        self.chart = chart
    }
    
    func updateGeometry(_ chart: ChartData, vertexBuffer: MTLBuffer, indexBuffer: MTLBuffer) {
        let points = chart.points
        if points.isEmpty {
            return
        }
        
        let indCount = (points.count - 1) * 5
        let vb = vertexBuffer.contents().bindMemory(to: ChartRenderVertex.self, capacity: points.count)
        let ib = indexBuffer.contents().bindMemory(to: UInt16.self, capacity: indCount)
        vb[0].position.x = 0
        
        let vertexColor: float4
        if let components = chart.display?.color?.cgColor.components {
            vertexColor = float4.init(Float(components[0]), Float(components[1]), Float(components[2]), Float(self.alpha))
        } else {
            vertexColor = float4.init(0, 0, 0, Float(self.alpha))
        }
        
        let pointsNumber = points.count
        for vertexNumber in 0 ..< pointsNumber {
            let isLast = vertexNumber >= pointsNumber - 1
            let point = points[vertexNumber]
            
            let currentCoord = point.coordinate
            let prevCoord: ChartData.ChartCoordinate
            if vertexNumber == 0 {
                prevCoord = ChartData.ChartCoordinate.init(x: currentCoord.x - 1, y: currentCoord.y)
            } else {
                prevCoord = points[vertexNumber - 1].coordinate
            }
            
            let nextCoord: ChartData.ChartCoordinate
            if isLast {
                nextCoord = ChartData.ChartCoordinate.init(x: currentCoord.x + 1, y: currentCoord.y)
            } else {
                nextCoord = points[vertexNumber + 1].coordinate
            }
            
            let leftNorm = CGPoint.init(x: -(currentCoord.y - prevCoord.y), y: currentCoord.x - prevCoord.x)
            let rightNorm = CGPoint.init(x: -(nextCoord.y - currentCoord.y), y: nextCoord.x - currentCoord.x)
            
            let vertexIndex = vertexNumber * 2
            
            vb[vertexIndex + 0].position.x = Float(currentCoord.x)
            vb[vertexIndex + 0].position.y = Float(currentCoord.y)
            vb[vertexIndex + 0].color = vertexColor
            vb[vertexIndex + 0].direction.x = 1
            
            vb[vertexIndex + 0].normal.x = Float(leftNorm.x)
            vb[vertexIndex + 0].normal.y = Float(leftNorm.y)
            
            vb[vertexIndex + 0].nextNormal.x = Float(rightNorm.x)
            vb[vertexIndex + 0].nextNormal.y = Float(rightNorm.y)
            
            
            vb[vertexIndex + 1].position.x = Float(currentCoord.x)
            vb[vertexIndex + 1].position.y = Float(currentCoord.y)
            vb[vertexIndex + 1].color = vertexColor
            vb[vertexIndex + 1].direction.x = -1
            
            vb[vertexIndex + 1].normal.x = Float(leftNorm.x)
            vb[vertexIndex + 1].normal.y = Float(leftNorm.y)
            
            vb[vertexIndex + 1].nextNormal.x = Float(rightNorm.x)
            vb[vertexIndex + 1].nextNormal.y = Float(rightNorm.y)
            
            if !isLast {
                let vertexIndexUInt16 = UInt16(vertexIndex)
                let indexIndex = vertexNumber * 6
                ib[indexIndex + 0] = vertexIndexUInt16
                ib[indexIndex + 1] = vertexIndexUInt16 + 2
                ib[indexIndex + 2] = vertexIndexUInt16 + 3
                ib[indexIndex + 3] = vertexIndexUInt16
                ib[indexIndex + 4] = vertexIndexUInt16 + 3
                ib[indexIndex + 5] = vertexIndexUInt16 + 1;
            }
        }
    }
    
    func render(withEncoder encoder: MTLRenderCommandEncoder, context: MetalContext) {

        guard let chart = self.chart else {
            return
        }
        
        let view = context.view
        
        let indexCount = (chart.points.count - 1) * 6;
        
        let viewPort = context.dimensionsConverter.convertViewPortToDisplayViewPort(context.viewPort)
        var viewportSize = vector_int4.init(Int32(viewPort.x),
                                                      Int32(viewPort.y),
                                                      Int32(viewPort.xEnd),
                                                      Int32(viewPort.yEnd))
        
        var screenSize = vector_int2.init(Int32(view.bounds.width), Int32(view.bounds.height))
        
        self.updateGeometry(chart, vertexBuffer: self.vertexBuffer, indexBuffer: self.indexBuffer)
        
        let vertexParamIndex = AAPLVertexInputIndexVertices
        let viewPortIndex = AAPLVertexInputIndexViewportSize
        let screenSizeIndex = AAPLVertexInputIndexScreenSize
        
        encoder.setVertexBuffer(self.vertexBuffer, offset: 0, index: vertexParamIndex)
        encoder.setVertexBytes(&viewportSize, length: MemoryLayout<vector_int4>.stride, index: viewPortIndex)
        encoder.setVertexBytes(&screenSize, length: MemoryLayout<vector_int2>.stride, index: screenSizeIndex)
        
        encoder.drawIndexedPrimitives(type: .triangle,
                                       indexCount: indexCount,
                                       indexType: .uint16,
                                       indexBuffer: self.indexBuffer,
                                       indexBufferOffset:0)
    }
    
}
