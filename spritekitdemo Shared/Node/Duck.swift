//
//  Duck.swift
//  spritekitdemo
//
//  Created by jinzhao wang on 2023/4/26.
//

import Foundation
import SpriteKit

class Duck: SKNode {
    var hasTarget: Bool!
    
    init(hasTarget: Bool = false) {
        super.init()
        self.hasTarget = hasTarget
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
