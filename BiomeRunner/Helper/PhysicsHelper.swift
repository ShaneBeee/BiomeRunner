//
//  PhysicsHelper.swift
//  BiomeRunner
//
//  Created by ShaneBee on 2019-12-21.
//  Copyright © 2019 ShaneBee. All rights reserved.
//

import SpriteKit

class PhysicsHelper {
    
    static func addPhysicsBody(to sprite:SKSpriteNode, with name:String) {
        
        switch name {
            case GameConstants.StringConstants.playerName:
                sprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: sprite.size.width / 2, height: sprite.size.height))
                sprite.physicsBody!.restitution = 0.0
                sprite.physicsBody!.allowsRotation = false
                sprite.physicsBody!.categoryBitMask = GameConstants.PhysicsCategories.playerCategory
                sprite.physicsBody!.collisionBitMask = GameConstants.PhysicsCategories.groundCategory | GameConstants.PhysicsCategories.finishedCategory
                sprite.physicsBody!.contactTestBitMask = GameConstants.PhysicsCategories.allCategory
            case GameConstants.StringConstants.finishLineName:
                sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
                sprite.physicsBody!.categoryBitMask = GameConstants.PhysicsCategories.finishedCategory
            case GameConstants.StringConstants.enemyName:
                sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
                sprite.physicsBody?.categoryBitMask = GameConstants.PhysicsCategories.enemyCategory
            case GameConstants.StringConstants.coinName, GameConstants.StringConstants.powerUpName,
                 _ where GameConstants.StringConstants.superCoinNames.contains(name):
                sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width/2)
                sprite.physicsBody!.categoryBitMask = GameConstants.PhysicsCategories.collectibleCategory
            default:
                sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        }
        
        if (name != GameConstants.StringConstants.playerName) {
            sprite.physicsBody!.contactTestBitMask = GameConstants.PhysicsCategories.playerCategory
            sprite.physicsBody!.isDynamic = false
        }
        
    }
    
    static func addPhysicsBody(to tileMap:SKTileMapNode, and tileInfo: String) {
        let tileSize = tileMap.tileSize
        
        for row in 0..<tileMap.numberOfRows {
            var tiles = [Int]()
            for col in 0..<tileMap.numberOfColumns {
                let tileDefinition = tileMap.tileDefinition(atColumn: col, row: row)
                let isUsedTile = tileDefinition?.userData?[tileInfo] as? Bool
                if (isUsedTile ?? false) {
                    tiles.append(1)
                } else {
                    tiles.append(0)
                }
            }
            if (tiles.contains(1)) {
                var platform = [Int]()
                for (index, tile) in tiles.enumerated() {
                    if (tile == 1 && index < (tileMap.numberOfColumns - 1)) {
                        platform.append(index)
                    } else if (!platform.isEmpty) {
                        let x = CGFloat(platform[0]) * tileSize.width
                        let y = CGFloat(row) * tileSize.height
                        let tileNode = GroundNode(with: CGSize(width: tileSize.width * CGFloat(platform.count), height: tileSize.height))
                        tileNode.position = CGPoint(x: x, y: y)
                        tileNode.anchorPoint = CGPoint.zero
                        tileMap.addChild(tileNode)
                        
                        platform.removeAll()
                    }
                }
            }
        }
    }
    
    static func addSolidPhysicsBody(to tileMap: SKTileMapNode) {
        let tileSize = tileMap.tileSize
        let halfWidth = CGFloat(tileMap.numberOfColumns) / (2.0 * tileSize.width)
        let halfHeight = CGFloat(tileMap.numberOfRows) / (2.0 * tileSize.height)
        
        for col in 0..<tileMap.numberOfColumns {
            for row in 0..<tileMap.numberOfRows {
                let tileDefinition = tileMap.tileDefinition(atColumn: col, row: row)
                let isEdgeTile = tileDefinition?.userData?["solid"] as? Bool
                if (isEdgeTile ?? false) {
                    let x = CGFloat(col) * tileSize.width - halfWidth
                    let y = CGFloat(row) * tileSize.height - halfHeight
                    let rect = CGRect(x: 0, y: 0, width: tileSize.width, height: tileSize.height)
                    let tileNode = SKShapeNode(rect: rect)
                    tileNode.position = CGPoint(x: x, y: y)
                    tileNode.physicsBody = SKPhysicsBody.init(rectangleOf: tileSize, center: CGPoint(x: tileSize.width / 2.0, y: tileSize.height / 2.0))
                    tileNode.physicsBody?.isDynamic = false
                    //tileNode.physicsBody?.collisionBitMask = playerCollisionMask | wallCollisionMask
                    //tileNode.physicsBody?.categoryBitMask = wallCollisionMask
                    tileNode.physicsBody?.collisionBitMask = GameConstants.PhysicsCategories.playerCategory | GameConstants.PhysicsCategories.solidCategory
                    tileNode.physicsBody?.categoryBitMask = GameConstants.PhysicsCategories.groundCategory
                    tileMap.addChild(tileNode)
                }
            }
        }
    }
    
}
