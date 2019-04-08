//
//  ALCancelable.swift
//
//
//  Created by Andre on 3/10/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation

typealias ALOnCancelledBlock = ()->()

protocol ALCancelable {
    func cancel()
    func onCancelled(_ cancelledBlock: @escaping ALOnCancelledBlock)
    
    var isCancelled: Bool {get}
}
