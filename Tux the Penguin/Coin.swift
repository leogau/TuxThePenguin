import SpriteKit

class Coin: SKSpriteNode, GameSprite {
    var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "goods.atlas")
    var value = 1
    
    let coinSound = SKAction.playSoundFileNamed("Coin.aif", waitForCompletion: false)
    
    func spawn(parentNode: SKNode, position: CGPoint,
        size: CGSize=CGSize(width: 26, height: 26)) {

            parentNode.addChild(self)
            self.size = size
            self.position = position
            self.physicsBody = SKPhysicsBody(circleOfRadius: size.width/2)
            self.physicsBody?.affectedByGravity = false
            self.physicsBody?.categoryBitMask = PhysicsCategory.coin.rawValue
            self.physicsBody?.collisionBitMask = 0
            
            self.texture = textureAtlas.textureNamed("coin-bronze.png")
    }
    
    func turnToGold() {
        self.texture = textureAtlas.textureNamed("coin-gold.png")
        self.value = 5
    }
    
    func onTap() {
        //
    }
    
    func collect() {
        self.physicsBody?.categoryBitMask = 0
        
        // Fade out, move up, and scale up the coin:
        let collectAnimation = SKAction.group([
            SKAction.fadeAlphaTo(0, duration: 0.2),
            SKAction.scaleTo(1.5, duration: 0.2),
            SKAction.moveBy(CGVector(dx: 0, dy: 25),
            duration: 0.2)
            ])
        // After fading it out, move the coin out of the way
        // and reset it to initial values until the encounter
        // system re-uses it:
        let resetAfterCollected = SKAction.runBlock {
            self.position.y = 5000
            self.alpha = 1
            self.xScale = 1
            self.yScale = 1
            self.physicsBody?.categoryBitMask =
            PhysicsCategory.coin.rawValue
        }
        // Combine the actions into a sequence:
        let collectSequence = SKAction.sequence([
            collectAnimation,
            resetAfterCollected
            ])
        // Run the collect animation:
        self.runAction(collectSequence)
        
        self.runAction(coinSound)
    }
}