//
//  GameScene.swift
//  BiomeRunner
//
//  Created by ShaneBee on 2019-12-20.
//  Copyright © 2019 ShaneBee. All rights reserved.
//

import SpriteKit
import GameController

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
    
    var gameState = GameState.ONGOING {
        willSet {
            switch newValue {
                case .READY:
                    player.state = .IDLE
                    pauseEnemies(bool: false)
                case .ONGOING:
                    player.state = .RUNNING
                    pauseEnemies(bool: false)
                case .PAUSED:
                    player.state = .IDLE
                    pauseEnemies(bool: true)
                case .FINISHED:
                    player.state = .IDLE
                    pauseEnemies(bool: true)
            }
        }
    }
    
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
        observeGameController()
    }
    
    func createLayers() {
        worldLayer = Layer()
        worldLayer.zPosition = GameConstants.ZPositions.worldZ
        addChild(worldLayer)
        worldLayer.layerVelocity = CGPoint(x: -200.0, y: 0.0)
        
        load(level: levelKey)
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
            PhysicsHelper.addSolidPhysicsBody(to: tileMap)
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
        addPlayerActions()
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
    
    func addPlayerActions() {
        //let up = SKAction.moveBy(x: 0.0, y: frame.size.height / 10, duration: 0.4)
        let up = SKAction.moveBy(x: 0.0, y: player.size.height, duration: 0.4)
        up.timingMode = .easeOut
        
        player.createUserData(entry: up, forKey: GameConstants.StringConstants.jumpUpActionKey)
        
        let move = SKAction.moveBy(x: 0.0, y: player.size.height, duration: 0.4)
        let jump = SKAction.animate(with: player.jumpFrames, timePerFrame: 0.4 / Double(player.jumpFrames.count))
        let group = SKAction.group([move, jump])
        
        player.createUserData(entry: group, forKey: GameConstants.StringConstants.brakeDescendActionKey)
        
        let right = SKAction.repeatForever(SKAction.moveBy(x: 120.0, y: 0.0, duration: 0.4))
        player.createUserData(entry: right, forKey: GameConstants.StringConstants.moveRightActionKey)
        
        let left = SKAction.repeatForever(SKAction.moveBy(x: -120.0, y: 0.0, duration: 0.4))
        player.createUserData(entry: left, forKey: GameConstants.StringConstants.moveLeftActionKey)
    }
    
    func jump() {
        if (gameState == .ONGOING) {
            // If player is airborne make them brake
            if (player.airborne) {
                brakeDescend()
            } else {
                player.airborne = true
                player.turnGravity(on: false)
                player.run(player.userData?.value(forKey: GameConstants.StringConstants.jumpUpActionKey) as! SKAction) {
                    self.player.turnGravity(on: true)
                }
            }
        }
    }
    
    func move(direction: Float) {
        if (gameState == .ONGOING) {
            // Move left or right
            if (direction != 0) {
                if (player.airborne || player.state == .RUNNING) {
                    return
                }
                player.state = .RUNNING
                //player.run(SKAction.repeatForever(SKAction.moveBy(x: CGFloat(direction * 100.0), y: 0, duration: 0.4)), withKey: "Running")
                player.run(direction > 0 ? player.userData?.value(forKey: GameConstants.StringConstants.moveRightActionKey) as! SKAction : player.userData?.value(forKey: GameConstants.StringConstants.moveLeftActionKey) as! SKAction, withKey: "Running")
                player.xScale = abs(player.xScale) * (direction > 0 ? 1 : -1)
                
            // Stop movement
            } else {
                player.state = .IDLE
                player.removeAction(forKey: "Running")
            }
        }
    }
    
    func brakeDescend() {
        if (!brake) {
            brake = true
            player.physicsBody?.velocity.dy = 0.0
            
            player.run(player.userData?.value(forKey: GameConstants.StringConstants.brakeDescendActionKey) as! SKAction)
        }
    }
    
    func handleEnemyContact() {
        if (!player.invincible) {
            die(reason: 0)
        }
    }
    
    func die(reason: Int) {
        gameState = .FINISHED
        player.turnGravity(on: false)
        let deathAnimation: SKAction!
        switch reason {
            case 0:
                deathAnimation = SKAction.animate(with: player.dieFrames, timePerFrame: 0.1, resize: true, restore: true)
            case 1:
                let up = SKAction.moveTo(y: frame.midY / 2, duration: 0.25)
                let wait = SKAction.wait(forDuration: 0.1)
                let down = SKAction.moveTo(y: -player.size.height, duration: 0.2)
                deathAnimation = SKAction.sequence([up, wait, down])
            default:
                deathAnimation = SKAction.animate(with: player.dieFrames, timePerFrame: 0.1, resize: true, restore: true)
        }
        player.run(deathAnimation) {
            self.player.removeFromParent()
            //self.createAndShowPopup(type: 1, title: GameConstants.StringConstants.failedKey)
        }
    }
    
    func pauseEnemies(bool: Bool) {
        for enemy in tileMap[GameConstants.StringConstants.enemyName] {
            enemy.isPaused = bool
        }
    }
    
    // --- CONTROLLER STUFF ---
    
    // Function to run intially to lookout for any MFI or Remote Controllers in the area
    func observeGameController() {
        NotificationCenter.default.addObserver(self, selector: #selector(connectControllers), name: NSNotification.Name.GCControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disconnectControllers), name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
    }
    
    // This Function is called when a controller is connected to the Apple TV
    @objc func connectControllers() {
        //Unpause the Game if it is currently paused
        self.isPaused = false
        //Used to register the Nimbus Controllers to a specific Player Number
        var indexNumber = 0
        // Run through each controller currently connected to the system
        for controller in GCController.controllers() {
            //Check to see whether it is an extended Game Controller (Such as a Nimbus)
            if controller.extendedGamepad != nil {
                controller.playerIndex = GCControllerPlayerIndex.init(rawValue: indexNumber)!
                indexNumber += 1
                setupControllerControls(controller: controller)
            }
        }
    }
    
    // Function called when a controller is disconnected from the Apple TV
    @objc func disconnectControllers() {
        // Pause the Game if a controller is disconnected ~ This is mandated by Apple
        self.isPaused = true
    }
    
    // Function called to setup controllers
    func setupControllerControls(controller: GCController) {
        //Function that check the controller when anything is moved or pressed on it
        controller.extendedGamepad?.valueChangedHandler = {
            (gamepad: GCExtendedGamepad, element: GCControllerElement) in
            // Add movement in here for sprites of the controllers
            self.controllerInputDetected(gamepad: gamepad, element: element, index: controller.playerIndex.rawValue)
        }
    }
    
}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch contactMask {
            case GameConstants.PhysicsCategories.playerCategory | GameConstants.PhysicsCategories.groundCategory:
                player.airborne = false
                player.turnGravity(on: true)
                brake = false
            case GameConstants.PhysicsCategories.playerCategory | GameConstants.PhysicsCategories.solidCategory:
                player.airborne = false
                player.turnGravity(on: true)
                brake = false
            case GameConstants.PhysicsCategories.playerCategory | GameConstants.PhysicsCategories.finishedCategory:
                //finishGame()
                break
            case GameConstants.PhysicsCategories.playerCategory | GameConstants.PhysicsCategories.enemyCategory:
                handleEnemyContact()
            case GameConstants.PhysicsCategories.playerCategory | GameConstants.PhysicsCategories.frameCategory:
                physicsBody = nil
                die(reason: 1)
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
                //player.airborne = true
                player.turnGravity(on: true)
            default:
                break
        }
    }
    
}
