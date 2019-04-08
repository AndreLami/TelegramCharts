//
//  MetalSurface.swift
//  GraphPresenter
//
//  Created by Andre on 3/28/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import MetalKit

class MetalSurface: RenderSurface<IMetalSurfaceRenderer>, MTKViewDelegate {
    
    private var isUpToDate = false
    
    private var internalView: MTKView!
    private let internalIdentifier: String
    
    private var renderers = [IMetalSurfaceRenderer]()
    
    private var bufferLock = pthread_rwlock_t()
    
    private var device: MTLDevice?
    private var commandQueue: MTLCommandQueue?
    private var pipelineState: MTLRenderPipelineState?
    
    private  let metalContextMakerBlock: (MTKView) -> MetalContext
    
    override var identifier: String {
        return internalIdentifier
    }
    
    override var view: UIView {
        return internalView
    }
    
    init(withIdentifier identifier: String, surfaceParams: MetalSurfaceParams, metalContextMakerBlock: @escaping (MTKView) -> MetalContext) {
        self.internalIdentifier = identifier
        self.metalContextMakerBlock = metalContextMakerBlock
        
        super.init()
        
        self.setup(surfaceParams: surfaceParams)
    }
    
    
    
    override func invalidate() {
        self.isUpToDate = false
        self.internalView.setNeedsDisplay()
    }
    
    override func addRenderer(_ renderer: IMetalSurfaceRenderer) {
        self.renderers.append(renderer)
        renderer.setupWithView(self.internalView)
    }
    
    override func removeRenderer(_ renderer: IMetalSurfaceRenderer) {
        self.renderers = self.renderers.filter { (candidate) -> Bool in
            return candidate !== renderer
        }
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        if self.isUpToDate {
            return
        }
        
        self.isUpToDate = true
        
        let metalContext = self.metalContextMakerBlock(self.internalView)
        
        pthread_rwlock_wrlock(&self.bufferLock)
        
        let commandBuffer = self.commandQueue!.makeCommandBuffer()
        commandBuffer?.label = "ChartComand"
        
        commandBuffer!.addCompletedHandler { (buffer) in
            pthread_rwlock_unlock(&self.bufferLock)
        }
        
        let renderPassDescriptor = view.currentRenderPassDescriptor
        
        if renderPassDescriptor != nil
        {
            let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor!)
            renderEncoder!.label = "ChartEncoder";
            renderEncoder!.setCullMode(.none)
            renderEncoder?.setRenderPipelineState(self.pipelineState!)
            
            for renderer in self.renderers {
                renderer.render(withEncoder: renderEncoder!, context: metalContext)
            }
            
            
            renderEncoder!.endEncoding()
            commandBuffer!.present(view.currentDrawable!)
        }
        
        commandBuffer?.commit()
    }
    
}

private extension MetalSurface {
    
    func setup(surfaceParams: MetalSurfaceParams) {
        let metalView = MTKView()
        metalView.device = MTLCreateSystemDefaultDevice()
        metalView.isOpaque = false
        metalView.clearColor = MTLClearColor.init(red: 0, green: 0, blue: 0, alpha: 0)
        metalView.sampleCount = 4;
        metalView.delegate = self

        self.internalView = metalView
        
        pthread_rwlock_init(&self.bufferLock, nil)
        
        self.device = metalView.device
        
        let defaultLibrary = self.device!.makeDefaultLibrary()
        let vertexFunction = defaultLibrary!.makeFunction(name: surfaceParams.vertexFunction)
        let fragmentFunction = defaultLibrary!.makeFunction(name: surfaceParams.fragmentFunction)
        
        
        
        // Create a reusable pipeline state
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        
        pipelineStateDescriptor.label = "ChartPipline";
        pipelineStateDescriptor.sampleCount = metalView.sampleCount;
        pipelineStateDescriptor.vertexFunction = vertexFunction;
        pipelineStateDescriptor.fragmentFunction = fragmentFunction;
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat;
        let renderAttachment = pipelineStateDescriptor.colorAttachments[0]
        renderAttachment?.isBlendingEnabled = true
        renderAttachment?.alphaBlendOperation = .add
        renderAttachment?.rgbBlendOperation = .add
        renderAttachment?.sourceRGBBlendFactor = .sourceAlpha
        renderAttachment?.sourceAlphaBlendFactor = .sourceAlpha
        renderAttachment?.destinationRGBBlendFactor = .oneMinusSourceAlpha
        renderAttachment?.destinationAlphaBlendFactor = .oneMinusSourceAlpha
        
        pipelineStateDescriptor.depthAttachmentPixelFormat = metalView.depthStencilPixelFormat;
        pipelineStateDescriptor.stencilAttachmentPixelFormat = metalView.depthStencilPixelFormat;
        
        self.pipelineState = try! self.device!.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        self.commandQueue = self.device!.makeCommandQueue()
    }
    
}
