import SpriteKit

class Player : SKSpriteNode, GameSprite {
    var textureAtlas:SKTextureAtlas = SKTextureAtlas(named: "pierre.atlas")
    
    var flyAnimation = SKAction()
    var soarAnimation = SKAction()
    var damageAnimation = SKAction()
    var dieAnimation = SKAction()
    
    var flapping = false
    let maxFlappingForce:CGFloat = 57000
    let maxHeight:CGFloat = 1000
    var forwardVelocity:CGFloat = 200
    
    var health:Int = 3
    var invulnerable = false
    var damaged = false
    
    let powerupSound = SKAction.playSoundFileNamed("Powerup.aif", waitForCompletion: false)
    let hurtSound = SKAction.playSoundFileNamed("Hurt.aif", waitForCompletion: false)
    
    func spawn(parentNode: SKNode, position: CGPoint, size: CGSize=CGSize(width: 64, height: 64)) {
        parentNode.addChild(self)
        createAnimations()
        self.size = size
        self.position = position
        self.runAction(soarAnimation, withKey: "soarAnimation")
        
        let bodyTexture = textureAtlas.textureNamed("pierre-flying-3.png")
        self.physicsBody = SKPhysicsBody(texture: bodyTexture, size: size)
        self.physicsBody?.linearDamping = 0.9
        self.physicsBody?.mass = 30
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.penguin.rawValue
        self.physicsBody?.contactTestBitMask =
            PhysicsCategory.enemy.rawValue |
            PhysicsCategory.ground.rawValue |
            PhysicsCategory.powerup.rawValue |
            PhysicsCategory.coin.rawValue
        
        let dotEmitter = SKEmitterNode(fileNamed: "PierrePath.sks")
        dotEmitter!.particleZPosition = -1
        self.addChild(dotEmitter!)
        dotEmitter?.targetNode = self.parent
        
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.velocity.dy = 50
        let startGravitySequence = SKAction.sequence([
            SKAction.waitForDuration(0.6),
            SKAction.runBlock({
                self.physicsBody?.affectedByGravity = true
            })
        ])
        self.runAction(startGravitySequence)
    }
    
    func createAnimations() {
        let rotateUpAction = SKAction.rotateToAngle(0, duration: 0.475)
        rotateUpAction.timingMode = .EaseOut
        let rotateDownAction = SKAction.rotateToAngle(-1, duration: 0.8)
        rotateDownAction.timingMode = .EaseIn
        
        let flyFrames: [SKTexture] = [
            textureAtlas.textureNamed("pierre-flying-1.png"),
            textureAtlas.textureNamed("pierre-flying-2.png"),
            textureAtlas.textureNamed("pierre-flying-3.png"),
            textureAtlas.textureNamed("pierre-flying-4.png"),
            textureAtlas.textureNamed("pierre-flying-3.png"),
            textureAtlas.textureNamed("pierre-flying-2.png")
        ]
        let flyAction = SKAction.animateWithTextures(flyFrames, timePerFrame: 0.03)
        flyAnimation = SKAction.group([
            SKAction.repeatActionForever(flyAction),
            rotateUpAction])
        
        let soarFrames: [SKTexture] = [textureAtlas.textureNamed("pierre-flying-1.png")]
        let soarAction = SKAction.animateWithTextures(soarFrames, timePerFrame: 1)
        soarAnimation = SKAction.group([
            SKAction.repeatActionForever(soarAction),
            rotateDownAction])
        
        let damageStart = SKAction.runBlock({
            self.physicsBody?.categoryBitMask = PhysicsCategory.damagedPenguin.rawValue
            self.physicsBody?.collisionBitMask = ~PhysicsCategory.enemy.rawValue
        })
        
        let slowFade = SKAction.sequence([
            SKAction.fadeAlphaTo(0.3, duration: 0.35),
            SKAction.fadeAlphaTo(0.7, duration: 0.35)
            ])
        
        let fastFade = SKAction.sequence([
            SKAction.fadeAlphaTo(0.3, duration: 0.2),
            SKAction.fadeAlphaTo(0.7, duration: 0.2)
            ])
        
        let fadeOutAndIn = SKAction.sequence([
            SKAction.repeatAction(slowFade, count: 2),
            SKAction.repeatAction(fastFade, count: 5),
            SKAction.fadeAlphaTo(1, duration: 0.15)
            ])
        
        let damageEnd = SKAction.runBlock({
            self.physicsBody?.categoryBitMask = PhysicsCategory.penguin.rawValue
            self.physicsBody?.collisionBitMask = 0xFFFFFFFF
            self.damaged = false
        })
        
        self.damageAnimation = SKAction.sequence([
            damageStart,
            fadeOutAndIn,
            damageEnd
            ])
        
        let startDie = SKAction.runBlock({
            self.texture = self.textureAtlas.textureNamed("pierre-dead.png")
            self.physicsBody?.affectedByGravity = false
            self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            self.physicsBody?.collisionBitMask = PhysicsCategory.ground.rawValue
        })
        
        let endDie = SKAction .runBlock({
            self.physicsBody?.affectedByGravity = true
        })
        
        self.dieAnimation = SKAction.sequence([
            startDie,
            SKAction.scaleTo(1.3, duration: 0.05),
            SKAction.waitForDuration(0.5),
            SKAction.rotateToAngle(3, duration: 1.5),
            SKAction.waitForDuration(0.5),
            endDie
            ])
    }
    
    func onTap() {
        //
    }
    
    func update() {
        if self.flapping {
            var forceToApply = maxFlappingForce
            
            if position.y > 600 {
                let percentageOfMaxHeight = position.y / maxHeight
                let flappingForceSubtraction = percentageOfMaxHeight * maxFlappingForce
                forceToApply -= flappingForceSubtraction
            }
            
            self.physicsBody?.applyForce(CGVector(dx: 0, dy: forceToApply))
        }
        
        if self.physicsBody?.velocity.dy > 300 {
            self.physicsBody?.velocity.dy = 300
        }
        
        self.physicsBody?.velocity.dx = self.forwardVelocity
    }
    
    func startFlapping() {
        if self.health <= 0 {
            return
        }
        
        self.removeActionForKey("soarAnimation")
        self.runAction(flyAnimation, withKey: "flapAnimation")
        self.flapping = true
    }
    
    func stopFlapping() {
        if self.health <= 0 {
            return
        }
        
        self.removeActionForKey("flapAnimation")
        self.runAction(soarAnimation, withKey: "soarAnimation")
        self.flapping = false
    }
    
    func die() {
        self.alpha = 1
        self.removeAllActions()
        self.runAction(self.dieAnimation)
        self.flapping = false
        self.forwardVelocity = 0
        
        if let gameScene = self.parent?.parent as? GameScene {
            gameScene.gameOver()
        }
    }
    
    func takeDamage() {
        if self.invulnerable || self.damaged {
            return
        }
        self.damaged = true
        self.health -= 1
        if self.health == 0 {
            die()
        } else {
            self.runAction(self.damageAnimation)
        }
        
        self.runAction(hurtSound)
    }
    
    func starPower() {
        // Remove any existing star power-up animation, if
        // the player is already under the power of star
        self.removeActionForKey("starPower")
        // Grant great forward speed:
        self.forwardVelocity = 400
        // Make the player invulnerable:
        self.invulnerable = true
        // Create a sequence to scale the player larger,
        // wait 8 seconds, then scale back down and turn off
        // invulnerability, returning the player to normal:
        let starSequence = SKAction.sequence([
            SKAction.scaleTo(1.5, duration: 0.3),
            SKAction.waitForDuration(8),
            SKAction.scaleTo(1, duration: 1),
            SKAction.runBlock {
            self.forwardVelocity = 200
            self.invulnerable = false
            }
            ])
        // Execute the sequence:
        self.runAction(starSequence, withKey: "starPower")
        
        self.runAction(powerupSound)
    }
}