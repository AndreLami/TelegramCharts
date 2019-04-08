//
//  ALOperation.swift
//
//
//  Created by Andre on 3/10/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation

protocol ALOperation {
    
    func perform() -> ALTask
    var runningTask: ALTask? {get}
}
