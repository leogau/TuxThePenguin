import SpriteKit

class Ground: SKSpriteNode, GameSprite {
    var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "ground.atlas")
    var groundTexture: SKTexture?
    
    var jumpWidth = CGFloat()
    var jumpCount = CGFloat(1)
    
    func spawn(parentNode: SKNode, position: CGPoint, size: CGSize) {
        parentNode.addChild(self)
        
        self.size = size
        self.position = position
        
        self.anchorPoint = CGPointMake(0,1)
        
        if groundTexture == nil {
            groundTexture = textureAtlas.textureNamed("ice-tile.png")
        }
        
        createChildren()
        
        let pointTopRight = CGPoint(x: size.width, y: 0)
        self.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointZero, toPoint: pointTopRight)
        self.physicsBody?.categoryBitMask = PhysicsCategory.ground.rawValue
    }
    
    func createChildren() {
        if let texture = groundTexture {
            var tileCount:CGFloat = 0
            let textureSize = texture.size()
            
            let tileSize = CGSize(width: textureSize.width/2, height: textureSize.height/2)
            
            while tileCount * tileSize.width < self.size.width {
                let tileNode = SKSpriteNode(texture: texture)
                tileNode.size = tileSize
                tileNode.position.x = tileCount * tileSize.width
                tileNode.anchorPoint = CGPoint(x: 0, y: 1)
                self.addChild(tileNode)
                
                tileCount += 1
            }
            
            jumpWidth = tileSize.width * floor(tileCount/3)
        }
    }
    
    func checkForReposition(playerProgress:CGFloat) {
        let groundJumpPosition = jumpWidth * jumpCount
        
        if playerProgress >= groundJumpPosition {
            self.position.x += jumpWidth
            jumpCount += 1
        }
    }
    
    func onTap() {}
}
