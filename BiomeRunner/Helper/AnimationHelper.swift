//
//  AnimationHelper.swift
//  BiomeRunner
//
//  Created by ShaneBee on 2019-12-21.
//  Copyright © 2019 ShaneBee. All rights reserved.
//

import SpriteKit

class AnimationHelper {
    
    static func loadTextures(from atlas:SKTextureAtlas, withName name:String) -> [SKTexture] {
        var textures = [SKTexture]()
        
        for index in 0..<atlas.textureNames.count {
            let textureName = name + String(index)
            textures.append(atlas.textureNamed(textureName))
        }
        return textures
    }
    
}
