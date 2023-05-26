//
//  FireButton.swift
//  spritekitdemo
//
//  Created by jinzhao wang on 2023/5/15.
//

import Foundation
import SpriteKit

class FireButton: SKSpriteNode {
    var isRealoading = false
    
    var isPressed: Bool = false {
        didSet {
            guard !isRealoading else { return }
            
            if isPressed {
                texture = SKTexture(imageNamed: Texture.pressed.rawValue)
            } else {
                texture = SKTexture(imageNamed: Texture.normal.rawValue)
            }
        }
    }
    
    init() {
        let texture = SKTexture(imageNamed: Texture.normal.rawValue)
        super.init(texture: texture, color: .clear, size: texture.size())
        
        name = "fire"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemeted")
    }
}

