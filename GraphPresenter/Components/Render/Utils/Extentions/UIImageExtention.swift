//
//  UIImageExtention.swift
//  ChartPresenter
//
//  Created by Andre on 3/14/19.
//  Copyright © 2019 BB. All rights reserved.
//

import UIKit

extension UIImage {
    
    public func tintImageWith(tintColor: UIColor) -> UIImage {
        return self.tintedImageWithColor(tintColor: tintColor, blendMode: .destinationIn)
    }
    
    private func tintedImageWithColor(tintColor: UIColor, blendMode: CGBlendMode) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0);
        
        tintColor.setFill()
        
        let bounds = CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height)
        
        UIRectFill(bounds);
        
        self.draw(in: bounds, blendMode: blendMode, alpha: 1.0)
        
        if blendMode != .destinationIn {
            self.draw(in: bounds, blendMode: .destinationIn, alpha: 1.0)
        }
        
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return tintedImage!;
    }
    
}
