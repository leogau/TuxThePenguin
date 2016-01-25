import SpriteKit

class Blade: SKSpriteNode, GameSprite {
    var textureAtlas = SKTextureAtlas(named: "enemies.atlas")
    var spinAnimation = SKAction()
    
    func spawn(parentNode: SKNode, position: CGPoint, size: CGSize=CGSize(width: 185, height: 92)) {
        parentNode.addChild(self)
        self.size = size
        self.position = position
        self.physicsBody = SKPhysicsBody(
            texture: textureAtlas.textureNamed("blade-1.png"),
            size: size)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.dynamic = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.enemy.rawValue
        self.physicsBody?.collisionBitMask = ~PhysicsCategory.damagedPenguin.rawValue
        
        createAnimations()
        self.runAction(spinAnimation)
    }
    
    func createAnimations() {
        let spinFrames:[SKTexture] = [
            textureAtlas.textureNamed("blade-1.png"),
            textureAtlas.textureNamed("blade-2.png")
        ]
        let spinAction = SKAction.animateWithTextures(spinFrames, timePerFrame: 0.07)
        spinAnimation = SKAction.repeatActionForever(spinAction)
    }
    
    func onTap() {
        //
    }
}