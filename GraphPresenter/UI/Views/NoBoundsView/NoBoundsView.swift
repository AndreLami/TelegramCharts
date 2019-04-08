//
//  NoBoundsView.swift
//  GraphPresenter
//
//  Created by Andre on 3/22/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

class NoBoundsView: UIView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !self.clipsToBounds && !self.isHidden && self.alpha > 0 {
            for subview in self.subviews.reversed() {
                
                let pointInSubview = subview.convert(point, from: self);
                if let result = subview.hitTest(pointInSubview, with: event) {
                    return result
                }
            }
        }
        
        return nil;
    }
    
}
