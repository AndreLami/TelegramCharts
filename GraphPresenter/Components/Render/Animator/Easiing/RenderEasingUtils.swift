//
//  RenderEasingUtils.swift
//  ChartPresenter
//
//  Created by Andre on 3/15/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit


class RenderEasingUtils {
    
    private static var _quadraticEaseIn: IRenderEasing?
    private static var _quadraticEaseOut: IRenderEasing?
    
    static var quadraticEaseIn: IRenderEasing {
        if _quadraticEaseIn == nil {
            _quadraticEaseIn = BlockRenderEasing.init { (progress) -> CGFloat in
                return progress * progress
            }
        }
        
        return _quadraticEaseIn!
    }
    
    static var quadraticEaseOut: IRenderEasing {
        if _quadraticEaseIn == nil {
            _quadraticEaseIn = BlockRenderEasing.init { (progress) -> CGFloat in
                return -progress * (progress - 2)
            }
        }
        
        return _quadraticEaseIn!
    }
    
}

class BlockRenderEasing {
    
    private let easingBlock: (CGFloat) -> CGFloat
    
    init(withEasingBlock easingBlock: @escaping (CGFloat) -> CGFloat) {
        self.easingBlock = easingBlock
    }
}


extension BlockRenderEasing: IRenderEasing {
    
    func processProgress(_ progress: CGFloat) -> CGFloat {
        return self.easingBlock(progress)
    }
    
}
