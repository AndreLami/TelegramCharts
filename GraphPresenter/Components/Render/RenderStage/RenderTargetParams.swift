//
//  RenderTargetParams.swift
//  ChartPresenter
//
//  Created by Andre on 3/11/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation

class RenderTargetParams {
    
    let identifier: String
    var type: String? = nil
    
    init(withIdentifier identifier: String) {
        self.identifier = identifier
    }
    
}
