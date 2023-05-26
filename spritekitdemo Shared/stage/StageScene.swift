//
//  GameScene.swift
//  I Hate Duck
//
//  Created by Leonard Chen on 8/12/19.
//  Copyright © 2019 Leonard Chan. All rights reserved.
//

import SpriteKit
import GameplayKit

class StageScene: SKScene {
    
    var fire = FireButton()
    var duckScoreNode: SKNode!
    var targetScoreNode: SKNode!
    
    var magazine: Magazine!
    
    // touches
    var selectedNodes: [UITouch : SKSpriteNode] = [ : ]
    
    // Nodes
    var rifle: SKSpriteNode?
    var crosshair: SKSpriteNode?

    
    var gameManager: GameManager!
    
    // game state machine
    var gameStateMachine: GKStateMachine!
    
    var touchDifferent: (CGFloat, CGFloat)?
    
    class func newGameScene() -> StageScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "StageScene") as? StageScene else {
            print("Failed to load StageScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        return scene
    }
    
    override func didMove(to view: SKView) {
//        let node = generateDuck(hasTarget: true)
//        node.position = CGPoint(x: 240, y: 100)
//        node.zPosition = 6
//
//        addChild(node)
        gameManager = GameManager(scene: self)
        
        loadUI()
        
        Audio.sharedInstance.playSound(soundFileName: Sound.loop.rawValue)
        Audio.sharedInstance.player(with: Sound.loop.rawValue)?.volume = 0.3
        Audio.sharedInstance.player(with: Sound.loop.rawValue)?.numberOfLoops = -1
        
        
        gameStateMachine = GKStateMachine(states: [ReadyState(fire: fire, magazine: magazine),
                                                  ShootingState(fire: fire, magazine: magazine),
                                                  ReloadingState(fire: fire, magazine: magazine)])
        
        gameStateMachine.enter(ReadyState.self)
        
        gameManager.activeDucks()
        gameManager.activeTargets()
    }
}

// MARK: Gameloop
extension StageScene {
    override func update(_ currentTime: TimeInterval) {
        syncRilePosition()
        setBoundry()
    }
}

// MARK: Touches
extension StageScene {
    // touches began
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
        guard let crosshair = crosshair else { return }
        
        for touch in touches {
            let location = touch.location(in: self)
            if let node = self.atPoint(location) as? SKSpriteNode {
                if !selectedNodes.values.contains(crosshair) && !(node is FireButton) {
                    selectedNodes[touch] = crosshair
                    
                    let xDifference = touch.location(in: self).x - crosshair.position.x
                    let yDifference = touch.location(in: self).y - crosshair.position.y
                    touchDifferent = (xDifference, yDifference)
                }
                
                // actual shooting
                if node is FireButton {
                    selectedNodes[touch] = fire
                    
                    if !fire.isRealoading {
                        fire.isPressed = true
                        magazine.shoot()
                        
                        // play sound
                        Audio.sharedInstance.playSound(soundFileName: Sound.hit.rawValue)
                        
                        if magazine.needToReload() {
                            gameStateMachine.enter(ReloadingState.self)
                        }
                        
                        // find shoot node
                        let shootNode = gameManager.findShootNode(position: crosshair.position)
                        guard let (scoreText, shotImageName) = gameManager.findTextAndImageName(nodeName: shootNode.name) else { return }
                         
                        // add shot image
                        gameManager.addShot(imageName: shotImageName, node: shootNode, position: crosshair.position)
                        
                        // add score text
                        gameManager.addTextNode(position: crosshair.position, text: scoreText)
                        
                        // play sound
                        Audio.sharedInstance.playSound(soundFileName: Sound.score.rawValue)
                        
                        // update score node
                        
                        gameManager.update(text: String(gameManager.duckCount * gameManager.duckScore), node: &duckScoreNode)
                        gameManager.update(text: String(gameManager.targetCount * gameManager.targetScore), node: &targetScoreNode)
                        
                        // animate shoot node
                        shootNode.physicsBody = nil
                        if let node = shootNode.parent {
                            node.run(.sequence([.wait(forDuration: 0.2),
                                                .scaleY(to: 0, duration: 0.2)]))
                        }
                        
                    }
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
        guard let crosshair = crosshair else { return }
        guard let touchDifferent = touchDifferent else { return }
        
        for touch in touches {
            let location = touch.location(in: self)
            if let node = selectedNodes[touch] {
                if node.name == "fire" {
                    
                } else {
                    let newCrosshairPosition = CGPoint(x: location.x - touchDifferent.0, y: location.y - touchDifferent.1)
                    crosshair.position = newCrosshairPosition
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if selectedNodes[touch] != nil {
                if let fire = selectedNodes[touch] as? FireButton {
                    fire.isPressed = false
                }
                selectedNodes[touch] = nil
            }
        }
    }
}

// MARK: aciton
extension StageScene {
    func loadUI() {
        if let scene = scene {
            rifle = childNode(withName: "rifle") as? SKSpriteNode
            crosshair = childNode(withName: "crosshair") as? SKSpriteNode
            crosshair?.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        }
        
        // add fire button
        fire.position = CGPoint(x: 720, y: 80)
        fire.xScale = 1.7
        fire.yScale = 1.7
        fire.zPosition = 11
        addChild(fire)
        
        // add icons
        let duckIcon = SKSpriteNode(imageNamed: "icon_duck")
        duckIcon.position = CGPoint(x: 36, y: 365)
        duckIcon.zPosition = 11
        addChild(duckIcon)
        
        let targetIcon = SKSpriteNode(imageNamed: "icon_target")
        targetIcon.position = CGPoint(x: 36, y: 325)
        targetIcon.zPosition = 11
        addChild(targetIcon)
        
        // add score nodes
        duckScoreNode = gameManager.generateTextNode(text: "0")
        duckScoreNode.position = CGPoint(x: 60, y: 365)
        duckScoreNode.zPosition = 11
        duckScoreNode.xScale = 0.5
        duckScoreNode.yScale = 0.5
        addChild(duckScoreNode)
        
        targetScoreNode = gameManager.generateTextNode(text: "0")
        targetScoreNode.position = CGPoint(x: 60, y: 325)
        targetScoreNode.zPosition = 11
        targetScoreNode.xScale = 0.5
        targetScoreNode.yScale = 0.5
        addChild(targetScoreNode)
        
        // add empty magazine
        let magazineNode = SKNode()
        magazineNode.position = CGPoint(x: 760, y: 20)
        magazineNode.zPosition = 11
        
        var bullets = Array<Bullet>()
        
        for i in 0...gameManager.ammunitionQuantity-1 {
            let bullet = Bullet()
            bullet.position = CGPoint(x: -30 * i, y: 10)
            bullets.append(bullet)
            magazineNode.addChild(bullet)
        }
        
        magazine = Magazine(bullets: bullets)
        addChild(magazineNode)
    }
    
    
    
    func syncRilePosition() {
        guard let rifle = rifle else { return }
        guard let crosshair = crosshair else { return }
        
        rifle.position.x = crosshair.position.x + 100
    }
    
    func setBoundry() {
        guard let scene = scene else { return }
        guard let crosshair = crosshair else { return }
        
        if crosshair.position.x < scene.frame.minX {
            crosshair.position.x = scene.frame.minY
        }
        
        if crosshair.position.x > scene.frame.maxX {
            crosshair.position.x = scene.frame.maxX
        }
        
        if crosshair.position.y < scene.frame.minY {
            crosshair.position.y = scene.frame.minY
        }
        
        if crosshair.position.y > scene.frame.maxY {
            crosshair.position.y = scene.frame.maxY
        }
    }
}
