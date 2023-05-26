//
//  GameStateMachine.swift
//  spritekitdemo
//
//  Created by jinzhao wang on 2023/5/17.
//

import Foundation
import GameplayKit

class GameState: GKState {
    unowned var fire: FireButton
    unowned var magazine: Magazine
    
    init(fire: FireButton, magazine: Magazine) {
        self.fire = fire
        self.magazine = magazine
        
        super.init()
    }
}

class ReadyState: GameState {
    // 判断是否可以进入下一个State
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass is ShootingState.Type && !magazine.needToReload() {
            return true
        }
        return false
    }
    
    // 刚进入该类时，触发
    override func didEnter(from previousState: GKState?) {
        magazine.reloadIfNeeded()
        stateMachine?.enter(ShootingState.self)
    }
    
}

class ShootingState: GameState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass is ReloadingState.Type && magazine.needToReload() {
            return true
        }
        return false
    }
    
    override func didEnter(from previousState: GKState?) {
        fire.removeAction(forKey: ActionKey.reloading.rawValue)
        fire.run(.animate(with: [SKTexture.init(imageNamed: Texture.normal.rawValue)], timePerFrame: 0.1), withKey: ActionKey.reloading.rawValue)
    }
}

class ReloadingState: GameState {
    let reloadingTime: Double = 0.25
    let reloadingTexture = SKTexture(imageNamed: Texture.reloading.rawValue)
    lazy var fireButtonReloadingAction = {
        SKAction.sequence([SKAction.animate(with: [self.reloadingTexture], timePerFrame: 0.1),
                           SKAction.rotate(byAngle: 360, duration: 30)])
    }()
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass is ShootingState.Type && !magazine.needToReload() {
            return true
        }
        return false
    }
    
    let bulletTexture = SKTexture(imageNamed: Texture.texture.rawValue)
    lazy var bulletReloadingAction = {
        SKAction.animate(with: [bulletTexture], timePerFrame: 0.1)
    }()
    
    override func didEnter(from previousState: GKState?) {
        fire.isRealoading = true
        fire.removeAction(forKey: ActionKey.reloading.rawValue)
        fire.run(fireButtonReloadingAction, withKey: ActionKey.reloading.rawValue)
        
        for (i, bullet) in magazine.bullets.reversed().enumerated() {
            var action = [SKAction]()
            
            let waitAction = SKAction.wait(forDuration: TimeInterval(reloadingTime * Double(i)))
            action.append(waitAction)
            action.append(bulletReloadingAction)
            action.append(SKAction.run {
                // play sound
                Audio.sharedInstance.playSound(soundFileName: Sound.reload.rawValue)
                Audio.sharedInstance.player(with: Sound.reload.rawValue)?.volume = 0.3
            })
            action.append(SKAction.run {
                bullet.reloaded()
            })
            if i == magazine.capacity-1 {
                action.append(SKAction.run { [unowned self] in
                    self.fire.isRealoading = false
                    self.stateMachine?.enter(ShootingState.self)
                })
            }
            bullet.run(.sequence(action))
        }
    }
    
    
}






