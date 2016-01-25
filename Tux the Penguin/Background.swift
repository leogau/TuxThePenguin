import SpriteKit

class Background: SKSpriteNode {
    var movementMultiplier = CGFloat(0)
    var jumpAdjustment = CGFloat(0)
    let backgroundSize = CGSize(width: 1000, height: 1000)
    
    func spawn(parentNode:SKNode, imageName: String,
        zPosition:CGFloat, movementMultiplier:CGFloat) {
        
            self.anchorPoint = CGPointZero
            self.position = CGPoint(x: 0, y: 30)
            self.zPosition = zPosition
            self.movementMultiplier = movementMultiplier
            parentNode.addChild(self)
            
            for i in -1...1 {
                let newBGNode = SKSpriteNode(imageNamed: imageName)
                newBGNode.size = backgroundSize
                newBGNode.anchorPoint = CGPointZero
                newBGNode.position = CGPoint(x: i*Int(backgroundSize.width), y: 0)
                self.addChild(newBGNode)
            }
        
    }
    
    func updatePosition(playerProgress:CGFloat) {
        let adjustedPosition = jumpAdjustment + playerProgress * (1 - movementMultiplier)
        if playerProgress - adjustedPosition > backgroundSize.width {
            jumpAdjustment += backgroundSize.width
        }
        
        self.position.x = adjustedPosition
    }
}