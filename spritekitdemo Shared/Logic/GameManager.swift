//
//  GameManager.swift
//  spritekitdemo
//
//  Created by jinzhao wang on 2023/5/25.
//

import Foundation
import SpriteKit

class GameManager {
    unowned var scene: SKScene!
    
    // score
    var totalScore = 0
    let targetScore = 10
    let duckScore = 20
    
    // shoot count
    var duckCount = 0
    var targetCount = 0
    
    var duckMoveDuration: TimeInterval!
    let targetXPosition: [Int] = [160, 240, 320, 400, 480]
    var currentTargetXPostion: Int = 0
    
    let ammunitionQuantity = 5
    var zPositionDecimal = 0.001 {
        didSet {
            if zPositionDecimal == 1 {
                zPositionDecimal = 0.001
            }
        }
    }
    
    init(scene: SKScene!) {
        self.scene = scene
    }
    
    func generateDuck(hasTarget: Bool = false) -> Duck {
        var duck: SKSpriteNode
        var stick: SKSpriteNode
        var duckImageName: String
        var duckNodeName: String
        let node = Duck(hasTarget: hasTarget)
        var texture = SKTexture()
        
        if hasTarget {
            duckImageName = "duck_target/\(Int.random(in: 1...3))"
            texture = SKTexture(imageNamed: duckImageName)
            duckNodeName = "duck_target"
        } else {
            duckImageName = "duck/\(Int.random(in: 1...3))"
            texture = SKTexture(imageNamed: duckImageName)
            duckNodeName = "duck"
        }
        
        duck = SKSpriteNode(texture: texture)
        duck.name = duckNodeName
        duck.position = CGPoint(x: 0, y: 140)
        
        let physicsBody = SKPhysicsBody(texture: texture, alphaThreshold: 0.5, size: texture.size())
        physicsBody.affectedByGravity = false
        physicsBody.isDynamic = false
        duck.physicsBody = physicsBody
        
        stick = SKSpriteNode(imageNamed: "stick/\(Int.random(in: 1...2))")
        stick.anchorPoint = CGPoint(x: 0.5, y: 0)
        stick.position = CGPoint(x: 0, y: 0)
        
        duck.xScale = 0.8
        duck.yScale = 0.8
        stick.xScale = 0.8
        stick.yScale = 0.8
        
        node.addChild(stick)
        node.addChild(duck)
        
        return node
    }
    
    func generateTarget() -> Target {
        var target: SKSpriteNode
        var stick: SKSpriteNode
        let node = Target()
        let texture = SKTexture(imageNamed: "target/\(Int.random(in: 1...3))")
        target = SKSpriteNode(texture: texture)
        stick = SKSpriteNode(imageNamed: "stick_metal")
        
        target.xScale = 0.5
        target.yScale = 0.5
        target.position = CGPoint(x: 0, y: 95)
        target.name = "target"
        
        stick.xScale = 0.5
        stick.yScale = 0.5
        stick.anchorPoint = CGPoint(x: 0.5, y: 0)
        stick.position = CGPoint(x: 0, y: 0)
        
        node.addChild(stick)
        node.addChild(target)
        
        return node
    }
    
    func activeDucks() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { Timer in
            let duck = self.generateDuck(hasTarget: Bool.random())
            duck.position = CGPoint(x: -10, y: Int.random(in: 60...90))
            duck.zPosition = Bool.random() == true ? 4: 6
            duck.zPosition += CGFloat(self.zPositionDecimal)
            self.zPositionDecimal += 0.001
            
            if duck.hasTarget {
                self.duckMoveDuration = TimeInterval(Int.random(in: 2...4))
            } else {
                self.duckMoveDuration = TimeInterval(Int.random(in: 4...6))
            }
            
            self.scene.addChild(duck)
            duck.run(.sequence([.moveTo(x: 850, duration: self.duckMoveDuration), .removeFromParent()]))
        }
    }

    func activeTargets() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { Timer in
            let target = self.generateTarget()
            var xPosition = self.targetXPosition.randomElement()!
            
            while self.currentTargetXPostion == xPosition {
                xPosition = self.targetXPosition.randomElement()!
            }
            
            self.currentTargetXPostion = xPosition
            target.position = CGPoint(x: xPosition, y: Int.random(in: 120...145))
            target.zPosition = 1
            target.yScale = 0
            self.scene?.addChild(target)
            
            let physicsBody = SKPhysicsBody(circleOfRadius: 71/2)
            physicsBody.affectedByGravity = false
            physicsBody.isDynamic = false
            physicsBody.allowsRotation = false
            
            target.run(.sequence([
                .scaleY(to: 1, duration: 0.2),
                .run {
                    if let node = target.childNode(withName: "target") {
                        node.physicsBody = physicsBody
                    }
                },
                .wait(forDuration: 3.5),
                .scaleY(to: 0, duration: 0.2),
                .removeFromParent()]))
        }
    }
    
    func findShootNode(position: CGPoint) -> SKSpriteNode {
        var shootNode = SKSpriteNode()
        var biggestZPosition: CGFloat = 0.0
        
        scene.physicsWorld.enumerateBodies(at: position) { body, pointer in
            guard let node = body.node as? SKSpriteNode else { return }
            
            if node.name == "duck" || node.name == "duck_target" || node.name == "target" {
                if let parentNode = node.parent {
                    if parentNode.zPosition > biggestZPosition {
                        biggestZPosition = parentNode.zPosition
                        shootNode = node
                    }
                }
            }
        }
        
        return shootNode
    }
    
    func addShot(imageName: String, node: SKSpriteNode, position: CGPoint) {
        let convertedPosition = scene.convert(position, to: node)
        let shot = SKSpriteNode(imageNamed: imageName)
        
        shot.position = convertedPosition
        node.addChild(shot)
        shot.run(.sequence([.wait(forDuration: 2),
                            .fadeAlpha(to: 0, duration: 0.3),
                            .removeFromParent()]))
    }
    
    func findTextAndImageName(nodeName: String?) -> (String, String)? {
        var scoreText = ""
        var shotImageName = ""
        
        switch nodeName {
        case "duck":
            scoreText = "+\(duckScore)"
            duckCount += 1
            totalScore += duckScore
            shotImageName = Texture.shotBlue.rawValue
        case "duck_target":
            scoreText = "+\(duckScore + targetScore)"
            targetCount += 1
            duckCount += 1
            totalScore += duckScore + targetScore
            shotImageName = Texture.shotBlue.rawValue
        case "target":
            scoreText = "+\(targetScore)"
            targetCount += 1
            totalScore += targetScore
            shotImageName = Texture.shotBrown.rawValue
        default: return nil
        }
        
        return (scoreText, shotImageName)
    }
    
    func generateTextNode(text: String, leadingAnchorPoint: Bool = true) -> SKNode {
        let node = SKNode()
        var width: CGFloat = 0
        
        for character in text {
            var characterNode = SKSpriteNode()
            
            switch character {
            case "0": characterNode = SKSpriteNode(imageNamed: "number/0")
            case "1": characterNode = SKSpriteNode(imageNamed: "number/1")
            case "2": characterNode = SKSpriteNode(imageNamed: "number/2")
            case "3": characterNode = SKSpriteNode(imageNamed: "number/3")
            case "4": characterNode = SKSpriteNode(imageNamed: "number/4")
            case "5": characterNode = SKSpriteNode(imageNamed: "number/5")
            case "6": characterNode = SKSpriteNode(imageNamed: "number/6")
            case "7": characterNode = SKSpriteNode(imageNamed: "number/7")
            case "8": characterNode = SKSpriteNode(imageNamed: "number/8")
            case "9": characterNode = SKSpriteNode(imageNamed: "number/9")
            case "+": characterNode = SKSpriteNode(imageNamed: "number/+")
            case "*": characterNode = SKSpriteNode(imageNamed: "number/*")
            default: continue
            }
            
            node.addChild(characterNode)
            characterNode.anchorPoint = CGPoint(x: 0, y: 0.5)
            characterNode.position = CGPoint(x: width, y: 0)
            width += characterNode.size.width
        }
        
        if leadingAnchorPoint {
            return node
        } else {
            let anotherNode = SKNode()
            anotherNode.addChild(node)
            node.position = CGPoint(x: -width/2, y: 0)
            return anotherNode
        }
        
    }
    
    func addTextNode(position: CGPoint, text: String) {
        let scorePosition = CGPoint(x: position.x + 10, y: position.y + 30)
        let scoreNode = generateTextNode(text: text)
        scoreNode.position = scorePosition
        scoreNode.zPosition = 9
        scoreNode.xScale = 0.5
        scoreNode.yScale = 0.5
        scene.addChild(scoreNode)
        
        scoreNode.run(.sequence([.wait(forDuration: 0.5),
                                 .fadeOut(withDuration: 0.2),
                                 .removeFromParent()]))
    }
    
    func update(text: String, node: inout SKNode, leadingAnchorPoint: Bool = true) {
        let position = node.position
        let zPosition = node.zPosition
        let xScale = 0.5
        let yScale = 0.5
        node.removeFromParent()
        
        node = generateTextNode(text: text, leadingAnchorPoint: leadingAnchorPoint)
        node.zPosition = zPosition
        node.position = position
        node.xScale = xScale
        node.yScale = yScale
        scene.addChild(node)
    }
}
