import SpriteKit

class EncounterManager {
    let encounterNames: [String] = [
        "EncounterBats",
        "EncounterBees",
        "EncounterCoins"
    ]
    var encounters:[SKNode] = []
    var currentEncounterIndex:Int?
    var previousEncounterIndex:Int?
    
    init() {
        for encounterFileName in encounterNames {
            let encounter = SKNode()
            
            if let encounterScene = SKScene(fileNamed: encounterFileName) {
                for placeholder in encounterScene.children {
                    if let node = placeholder as? SKNode {
                        switch node.name! {
                            case "Bat":
                                let bat = Bat()
                            	bat.spawn(encounter, position: node.position)
                            case "Bee":
                                let bee = Bee()
                                bee.spawn(encounter, position: node.position)
                            case "Blade":
                                let blade = Blade()
                                blade.spawn(encounter, position: node.position)
                            case "Ghost":
                                let ghost = Ghost()
                            	ghost.spawn(encounter, position: node.position)
                            case "MadFly":
                                let madFly = MadFly()
                                madFly.spawn(encounter, position: node.position)
                            case "GoldCoin":
                                let coin = Coin()
                                coin.spawn(encounter, position: node.position)
                                coin.turnToGold()
                            case "BronzeCoin":
                                let coin = Coin()
                                coin.spawn(encounter, position: node.position)
                            default:
                                print("Name error: \(node.name)")
                        }
                    }
                }
            }
            
            encounters.append(encounter)
            saveSpritePositions(encounter)
        }
    }
    
    func addEncountersToWorld(world:SKNode) {
        for index in 0...encounters.count-1 {
            encounters[index].position = CGPoint(x: -2000, y: index*1000)
            world.addChild(encounters[index])
        }
    }
    
    func saveSpritePositions(node:SKNode) {
        for sprite in node.children {
            if let spriteNode = sprite as? SKSpriteNode {
                let initialPositionValue = NSValue(CGPoint: sprite.position)
                spriteNode.userData = ["initialPosition": initialPositionValue]
                saveSpritePositions(spriteNode)
            }
        }
    }
    
    func resetSpritePositions(node:SKNode) {
        for sprite in node.children {
            if let spriteNode = sprite as? SKSpriteNode {
                spriteNode.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                spriteNode.physicsBody?.angularVelocity = 0
                spriteNode.zRotation = 0
                if let initialPositionVal = spriteNode.userData?.valueForKey("initialPosition") as? NSValue {
                    spriteNode.position = initialPositionVal.CGPointValue()
                }
                
                resetSpritePositions(spriteNode)
            }
        }
    }
    
    func placeNextEncounter(currentXPos: CGFloat) {
        let encounterCount = UInt32(encounters.count)
        if encounterCount < 3 {
            return
        }
        
        var nextEncounterIndex:Int?
        var trulyNew:Bool?
        
        while trulyNew == false || trulyNew == nil {
            nextEncounterIndex = Int(arc4random_uniform(encounterCount))
            trulyNew = true
            
            if let currentIndex = currentEncounterIndex {
                if (nextEncounterIndex == currentIndex) {
                    trulyNew = false
                }
            }
            
            if let previousIndex = previousEncounterIndex {
                if (nextEncounterIndex == previousIndex) {
                    trulyNew = false
                }
            }
        }
        
        previousEncounterIndex = currentEncounterIndex
        currentEncounterIndex = nextEncounterIndex
        
        let encounter = encounters[currentEncounterIndex!]
        encounter.position = CGPoint(x: currentXPos+1000, y: 0)
        resetSpritePositions(encounter)
    }
}