//
//  Bullet.swift
//  spritekitdemo
//
//  Created by jinzhao wang on 2023/5/15.
//

import Foundation
import SpriteKit

class Bullet: SKSpriteNode {
    private var isEmpty = true
    
    init() {
        let texture = SKTexture(imageNamed: Texture.emptyTexture.rawValue)
        
        super.init(texture: texture, color: .clear, size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloaded() {
        isEmpty = false
    }
    
    func shoot() {
        isEmpty = true
        texture = SKTexture(imageNamed: Texture.emptyTexture.rawValue)
    }
    
    func wasShot() -> Bool {
        return isEmpty
    }
    
    func reloadIfNeeded() {
        if isEmpty {
            texture = SKTexture(imageNamed: Texture.texture.rawValue)
            isEmpty = false
        }
    }
}
