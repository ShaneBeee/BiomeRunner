//
//  GameViewController.swift
//  BiomeRunner
//
//  Created by ShaneBee on 2019-12-20.
//  Copyright © 2019 ShaneBee. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //presentMenuScene()
        presentGameScene(for: 1, in: 0)
    }
    

}

extension GameViewController: SceneManagerDelegate {
    
    func presentMenuScene() {
        let scene = MenuScene(size: view.bounds.size)
        scene.scaleMode = .aspectFill
        scene.sceneManagerDelegate = self
        present(scene: scene)
    }
    
    func presentLevelScene(for world: Int) {
    }
    
    func presentGameScene(for level: Int, in world: Int) {
        //let scene = GameScene(size: view.bounds.size, sceneManagerDelegate: self)
        let scene = GameScene(size: view.bounds.size, world: world, sceneManagerDelegate: self)
        
        //scene.scaleMode = .aspectFill
        present(scene: scene)
        
    }
    
    func present(scene: SKScene) {
        if let view = self.view as! SKView? {
            view.presentScene(scene)
            
            
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
            view.showsPhysics = true
        }
    }
    
}
