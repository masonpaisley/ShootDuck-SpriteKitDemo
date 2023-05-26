//
//  Magazine.swift
//  spritekitdemo
//
//  Created by jinzhao wang on 2023/5/15.
//

import Foundation
import SpriteKit

class Magazine {
    var bullets: [Bullet]!
    var capacity: Int!
    
    init(bullets: [Bullet]!) {
        self.bullets = bullets
        self.capacity = bullets.count
    }
    
    func shoot() {
        bullets.first { (bullet) -> Bool in
            bullet.wasShot() == false
        }?.shoot()
    }
    
    func needToReload() -> Bool {
        return bullets.allSatisfy { $0.wasShot() == true }
    }
    
    func reloadIfNeeded() {
        if needToReload() {
            for bullet in bullets {
                bullet.reloadIfNeeded()
            }
        }
    }
}
