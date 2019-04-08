//
//  IRenderEasing.swift
//  ChartPresenter
//
//  Created by Andre on 3/15/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

protocol IRenderEasing {
    
    func processProgress(_ progress: CGFloat) -> CGFloat
    
}



