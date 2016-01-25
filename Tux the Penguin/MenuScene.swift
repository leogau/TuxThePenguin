import SpriteKit

class MenuScene: SKScene {
    let textureAtlas = SKTextureAtlas(named: "hud.atlas")
    let startButton = SKSpriteNode()
    
    override func didMoveToView(view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.backgroundColor = UIColor(red: 0.4, green: 0.6, blue: 0.95, alpha: 1.0)
        let backgroundImage = SKSpriteNode(imageNamed: "Background-menu")
        backgroundImage.size = CGSize(width: 1024, height: 768)
        self.addChild(backgroundImage)
        
        let logoText = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        logoText.text = "Pierre Penguin"
        logoText.position = CGPoint(x: 0, y: 100)
        logoText.fontSize = 60
        self.addChild(logoText)
        
        let logoTextBottom = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        logoTextBottom.text = "Escapes the Antarctic"
        logoTextBottom.position = CGPoint(x: 0, y: 50)
        logoTextBottom.fontSize = 40
        self.addChild(logoTextBottom)
        
        startButton.texture = textureAtlas.textureNamed("button.png")
        startButton.size = CGSize(width: 295, height: 76)
        startButton.name = "StartBtn"
        startButton.position = CGPoint(x: 0, y: -20)
        self.addChild(startButton)
        
        let startText = SKLabelNode(fontNamed: "AvenirNext-HeavyItalic")
        startText.text = "START GAME"
        startText.verticalAlignmentMode = .Center
        startText.position = CGPoint(x: 0, y: 2)
        startText.fontSize = 40
        startText.name = "StartBtn"

        startButton.addChild(startText)
        
        let pulseAction = SKAction.sequence([
            SKAction.fadeAlphaTo(0.7, duration: 0.9),
            SKAction.fadeAlphaTo(1, duration: 0.9)
        ])
        startButton.runAction(SKAction.repeatActionForever(pulseAction))
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            let nodeTouched = nodeAtPoint(location)
            
            if nodeTouched.name == "StartBtn" {
                self.view?.presentScene(GameScene(size: self.size))
            }
        }
    }
}