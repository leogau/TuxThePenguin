//
//  GameScene.swift
//  Tux the Penguin
//
//  Created by Leo Gau on 1/14/16.
//  Copyright (c) 2016 Leo Gau. All rights reserved.
//

import SpriteKit

enum PhysicsCategory: UInt32 {
    case penguin = 1
    case damagedPenguin = 2
    case ground = 4
    case enemy = 8
    case coin = 16
    case powerup = 32
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let world = SKNode()
    let ground = Ground()
    let player = Player()
    let encounterManager = EncounterManager()
    let powerUpStar = Star()
    let hud = HUD()
    
    let initialPlayerPosition = CGPoint(x: 150, y: 250)

    var screenCenterY = CGFloat()
    var playerProgress = CGFloat()
    var nextEncounterSpawnPosition = CGFloat(150)
    
    var coinsCollected = 0
    var backgrounds: [Background] = []
    
    override func didMoveToView(view: SKView) {
        self.backgroundColor = UIColor(red: 0.4, green: 0.6, blue: 0.95, alpha: 1.0)

        self.addChild(world)
        
        screenCenterY = self.size.height / 2        
        
        let groundPosition = CGPoint(x: -self.size.width, y: 30)
        let groundSize = CGSize(width: self.size.width*3, height: 0)
        ground.spawn(world, position: groundPosition, size: groundSize)
        
        player.spawn(world, position: initialPlayerPosition)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -5)
        self.physicsWorld.contactDelegate = self
        
        encounterManager.addEncountersToWorld(self.world)
        encounterManager.encounters[0].position = CGPoint(x: 300, y: 0)
        
        powerUpStar.spawn(world, position: CGPoint(x: -2000, y: -2000))
    
        hud.createHudNodes(self.size)
        self.addChild(hud)
        hud.zPosition = 50
        
        for _ in 0...3 {
            backgrounds.append(Background())
        }
        
        backgrounds[0].spawn(world, imageName: "Background-1", zPosition: -5, movementMultiplier: 0.75)
        backgrounds[1].spawn(world, imageName: "Background-2", zPosition: -10, movementMultiplier: 0.5)
        backgrounds[2].spawn(world, imageName: "Background-3", zPosition: -15, movementMultiplier: 0.2)
        backgrounds[3].spawn(world, imageName: "Background-4", zPosition: -20, movementMultiplier: 0.1)
        
        self.runAction(SKAction.playSoundFileNamed("StartGame.aif", waitForCompletion: false))
    }
    
    override func didSimulatePhysics() {
        var worldYPos:CGFloat = 0
        
        if (player.position.y > screenCenterY) {
            let percentOfMaxHeight = (player.position.y - screenCenterY) / (player.maxHeight - screenCenterY)
            let scaleSubtraction = (percentOfMaxHeight > 1 ? 1 : percentOfMaxHeight) * 0.6
            let newScale = 1 - scaleSubtraction
            world.yScale = newScale
            world.xScale = newScale
            worldYPos = -(player.position.y * world.yScale - (self.size.height / 2))
        }
        
        let worldXPos = -(player.position.x * world.xScale - (self.size.width/3))
        world.position = CGPoint(x: worldXPos, y: worldYPos)
        
        playerProgress = player.position.x - initialPlayerPosition.x
        
        ground.checkForReposition(playerProgress)
        
        if player.position.x > nextEncounterSpawnPosition {
            encounterManager.placeNextEncounter(nextEncounterSpawnPosition)
            nextEncounterSpawnPosition += 1400
            
            let starRoll = Int(arc4random_uniform(10))
            if starRoll == 0 {
                if abs(player.position.x - powerUpStar.position.x) > 1200 {
                    let randomYPos = CGFloat(arc4random_uniform(400))
                    powerUpStar.position = CGPoint(x: nextEncounterSpawnPosition, y: randomYPos)
                    powerUpStar.physicsBody?.angularVelocity = 0
                    powerUpStar.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                }
            }
        }
        
        for background in self.backgrounds {
            background.updatePosition(playerProgress)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        player.startFlapping()
        
        for touch in (touches) {
            let location = touch.locationInNode(self)
            let nodeTouched = nodeAtPoint(location)
            if let gameSprite = nodeTouched as? GameSprite {
                gameSprite.onTap()
            }
            
            if nodeTouched.name == "restartGame" {
                self.view?.presentScene(GameScene(size: self.size), transition: .crossFadeWithDuration(0.6))
            } else if nodeTouched.name == "returnToMenu" {
                self.view?.presentScene(MenuScene(size: self.size), transition: .crossFadeWithDuration(0.6))
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        player.stopFlapping()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        player.stopFlapping()
    }
   
    override func update(currentTime: CFTimeInterval) {
        player.update()
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let otherBody: SKPhysicsBody
        let penguinMask = PhysicsCategory.penguin.rawValue |
            PhysicsCategory.damagedPenguin.rawValue
        
        if (contact.bodyA.categoryBitMask & penguinMask) > 0 {
            otherBody = contact.bodyB
        } else {
            otherBody = contact.bodyA
        }
        
        switch otherBody.categoryBitMask {
        case PhysicsCategory.ground.rawValue:
            player.takeDamage()
            hud.setHealthDisplay(player.health)
        case PhysicsCategory.enemy.rawValue:
            player.takeDamage()
            hud.setHealthDisplay(player.health)
        case PhysicsCategory.coin.rawValue:
            if let coin = otherBody.node as? Coin {
                coin.collect()
                self.coinsCollected += coin.value
                hud.setCoinCountDisplay(self.coinsCollected)
            }
        case PhysicsCategory.powerup.rawValue:
            player.starPower()
        default:
            print("contact with no game logic")
        }
    }
    
    func gameOver() {
        hud.showButtons()
    }
}
