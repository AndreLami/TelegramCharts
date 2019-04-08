//
//  ViewLayoutProtocol.swift
//  ChartPresenter
//
//  Created by Andre on 3/10/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

protocol IViewLayout {
    func layoutView(view: UIView)
}

typealias LayoutBlock = (UIView) -> Void

class ViewLayoutUtils {
    
    static func createLayout(withBlock layoutBlock: @escaping LayoutBlock) -> IViewLayout {
        return BlockViewLayout(layoutBlock: layoutBlock)
    }
}

private class BlockViewLayout: IViewLayout {
    
    let layoutBlock: LayoutBlock
    
    init(layoutBlock: @escaping LayoutBlock) {
        self.layoutBlock = layoutBlock
    }
    
    func layoutView(view: UIView) {
        self.layoutBlock(view)
    }
}
