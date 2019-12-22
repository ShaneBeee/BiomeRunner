//
//  GameScene.swift
//  BiomeRunner
//
//  Created by ShaneBee on 2019-12-20.
//  Copyright © 2019 ShaneBee. All rights reserved.
//

import SpriteKit

enum GameState {
    case READY, ONGOING, PAUSED, FINISHED
}

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    var sceneManagerDelegate: SceneManagerDelegate?
    
    var worldLayer: Layer!
    var mapNode: SKNode!
    var tileMap: SKTileMapNode!
    
    var player: Player!
    var touch = false
    var brake = false
    
    var world: Int
    var levelKey: String
    
    init(size: CGSize, world: Int, sceneManagerDelegate: SceneManagerDelegate) {
        self.world = world
        self.levelKey = "World_\(world)"
        self.sceneManagerDelegate = sceneManagerDelegate
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented... but why?!?")
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -6.0)
        
        physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: frame.minX, y: frame.minY), to: CGPoint(x: frame.maxX, y: frame.minY))
        physicsBody!.categoryBitMask = GameConstants.PhysicsCategories.frameCategory
        physicsBody!.contactTestBitMask = GameConstants.PhysicsCategories.playerCategory
        createLayers()
        isPaused = true
        isPaused = false
    }
    
    func createLayers() {
        worldLayer = Layer()
        worldLayer.zPosition = GameConstants.ZPositions.worldZ
        addChild(worldLayer)
        worldLayer.layerVelocity = CGPoint(x: -200.0, y: 0.0)
        
        load(level: levelKey) // TODO this is just a test on hold
        //load(level: "World_0")
        
    }
    
    func load(level: String) {
        if let levelNode = SKNode.unarchiveFromFile(file: level) {
            mapNode = levelNode
            worldLayer.addChild(mapNode)
            loadTileMap()
        }
    }
    
    func loadTileMap() {
        if let groundTiles = mapNode.childNode(withName: GameConstants.StringConstants.groundTilesName) as? SKTileMapNode {
            tileMap = groundTiles
            tileMap.scale(to: frame.size, width: false, multiplier: 1.0)
            PhysicsHelper.addPhysicsBody(to: tileMap, and: "ground")
            for child in groundTiles.children {
                if let sprite = child as? SKSpriteNode, sprite.name != nil {
                    ObjectHelper.handleChild(sprite: sprite, with: sprite.name!)
                }
            }
        }
        addPlayer()
    }
    
    func addPlayer() {
        player = Player(imageNamed: GameConstants.StringConstants.playerImageName)
        player.scale(to: frame.size, width: false, multiplier: 0.1)
        player.name = GameConstants.StringConstants.playerName
        PhysicsHelper.addPhysicsBody(to: player, with: player.name!)
        player.position = CGPoint(x: (frame.midX / 2.0) - 300, y: frame.midY + 300)
        player.zPosition = GameConstants.ZPositions.playerZ
        player.loadTextures()
        player.state = .IDLE
        addChild(player)
        //addPlayerActions()
    }
    
    override func didSimulatePhysics() {
        for node in tileMap[GameConstants.StringConstants.groundNodeName] {
            if let groundNode = node as? GroundNode {
                let groundY = (groundNode.position.y + groundNode.size.height) * tileMap.yScale
                let playerY = player.position.y - player.size.height / 3
                groundNode.isBodyActivated = playerY > groundY
            }
        }
    }
    
}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch contactMask {
            case GameConstants.PhysicsCategories.playerCategory | GameConstants.PhysicsCategories.groundCategory:
                player.airborne = false
                brake = false
            case GameConstants.PhysicsCategories.playerCategory | GameConstants.PhysicsCategories.finishedCategory:
                //finishGame()
                break
            case GameConstants.PhysicsCategories.playerCategory | GameConstants.PhysicsCategories.enemyCategory:
                //handleEnemyContact()
                break
            case GameConstants.PhysicsCategories.playerCategory | GameConstants.PhysicsCategories.frameCategory:
                physicsBody = nil
                //die(reason: 1)
            case GameConstants.PhysicsCategories.playerCategory | GameConstants.PhysicsCategories.collectibleCategory:
                //let collectible = contact.bodyA.node?.name == player.name ? contact.bodyB.node as! SKSpriteNode : contact.bodyA.node as! SKSpriteNode
                break
                //handleCollectible(sprite: collectible)
            
            default:
                break
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch contactMask {
            case GameConstants.PhysicsCategories.playerCategory | GameConstants.PhysicsCategories.groundCategory:
                player.airborne = true
            default:
                break
        }
    }
    
}
