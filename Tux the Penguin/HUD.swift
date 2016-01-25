import SpriteKit

class HUD: SKNode {
    var textureAtlas = SKTextureAtlas(named: "hud.atlas")
    var heartNodes:[SKSpriteNode] = []
    let coinCountText = SKLabelNode(text: "000000")
    
    let restartButton = SKSpriteNode()
    let menuButton = SKSpriteNode()
    
    func createHudNodes(screensize: CGSize) {
        let coinTextureAtlas:SKTextureAtlas = SKTextureAtlas(named: "goods.atlas")
        let coinIcon = SKSpriteNode(texture: coinTextureAtlas.textureNamed("coin-bronze.png"))
        let coinYPos = screensize.height - 23
        coinIcon.size = CGSize(width: 26, height: 26)
        coinIcon.position = CGPoint(x: 23, y: coinYPos)
        coinCountText.fontName = "AvenirNext-HeavyItalic"
        coinCountText.position = CGPoint(x: 41, y: coinYPos)
        coinCountText.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        coinCountText.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        self.addChild(coinCountText)
        self.addChild(coinIcon)
        
        for var index = 0; index < 3; index += 1 {
            let newHeartNode = SKSpriteNode(texture: textureAtlas.textureNamed("heart-full.png"))
            newHeartNode.size = CGSize(width: 46, height: 40)
            let xPos = CGFloat(index*60 + 33)
            let yPos = screensize.height - 66
            newHeartNode.position = CGPoint(x: xPos, y: yPos)
            heartNodes.append(newHeartNode)
            self.addChild(newHeartNode)
        }
        
        restartButton.texture = textureAtlas.textureNamed("button-restart.png")
        menuButton.texture = textureAtlas.textureNamed("button-menu.png")
        restartButton.name = "restartGame"
        menuButton.name = "returnToMenu"
        
        let centerOfHud = CGPoint(x: screensize.width/2, y: screensize.height/2)
        restartButton.position = centerOfHud
        menuButton.position = CGPoint(x: centerOfHud.x-140, y: centerOfHud.y)
        
        restartButton.size = CGSize(width: 140, height: 140)
        menuButton.size = CGSize(width: 70, height: 70)
    }
    
    func setCoinCountDisplay(newCoinCount: Int) {
        let formatter = NSNumberFormatter()
        formatter.minimumIntegerDigits = 6
        if let coinStr = formatter.stringFromNumber(newCoinCount) {
            coinCountText.text = coinStr
        }
    }
    
    func setHealthDisplay(newHealth:Int) {
        let fadeAction = SKAction.fadeAlphaTo(0.2, duration: 0.3)
        for var index=0; index < heartNodes.count; index+=1 {
            if index < newHealth {
                heartNodes[index].alpha = 1
            } else {
                heartNodes[index].runAction(fadeAction)
            }
        }
    }
    
    func showButtons() {
        restartButton.alpha = 0
        menuButton.alpha = 0
        
        self.addChild(restartButton)
        self.addChild(menuButton)
        
        let fadeAnimation = SKAction.fadeAlphaTo(1, duration: 0.4)
        restartButton.runAction(fadeAnimation)
        menuButton.runAction(fadeAnimation)
    }
}