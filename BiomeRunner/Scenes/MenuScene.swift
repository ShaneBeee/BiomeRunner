//
//  MenuScene.swift
//  BiomeRunner
//
//  Created by ShaneBee on 2019-12-21.
//  Copyright © 2019 ShaneBee. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    
    var sceneManagerDelegate: SceneManagerDelegate?
    
    override func didMove(to view: SKView) {
        layoutView()
    }
    
    func layoutView() {
        
        let startButton = SpriteKitButton(defaultButtonImage: GameConstants.StringConstants.playButton, action: goToLvelScene, index: 0)
        startButton.scale(to: frame.size, width: false, multiplier: 0.1)
        startButton.position = CGPoint(x: frame.midX, y: frame.midY)
        startButton.zPosition = GameConstants.ZPositions.hudZ
        addChild(startButton)
        
    }
    
    func goToLvelScene(_: Int) {
        sceneManagerDelegate?.presentGameScene(for: 1, in: 1)
    }
    
}
