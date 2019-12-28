//
//  Controls.swift
//  BiomeRunner
//
//  Created by ShaneBee on 2019-12-22.
//  Copyright © 2019 ShaneBee. All rights reserved.
//

import Foundation
import GameController
import SpriteKit

extension GameScene {
    
    func controllerInputDetected(gamepad: GCExtendedGamepad, element: GCControllerElement, index: Int) {
        
        // Left Thumbstick
        if (gamepad.leftThumbstick == element) {
            if (gamepad.leftThumbstick.xAxis.value != 0) {
                //print("Controller: \(index), LeftThumbstickXAxis: \(gamepad.leftThumbstick.xAxis.value)")
                if (gamepad.leftThumbstick.xAxis.value > 0) {
                    move(direction: 1)
                } else {
                    move(direction: -1)
                }
            }
            else if (gamepad.leftThumbstick.xAxis.value == 0) {
                // YOU CAN PUT CODE HERE TO STOP YOUR PLAYER FROM MOVING
                move(direction: 0)
            }
        }
        // Right Thumbstick
        if (gamepad.rightThumbstick == element) {
            if (gamepad.rightThumbstick.xAxis.value != 0) {
                print("Controller: \(index), rightThumbstickXAxis: \(gamepad.rightThumbstick.xAxis)")
            }
        }
        // D-Pad
        else if (gamepad.dpad == element) {
            if (gamepad.dpad.xAxis.value != 0) {
                print("Controller: \(index), D-PadXAxis: \(gamepad.rightThumbstick.xAxis)")
            }
            else if (gamepad.dpad.xAxis.value == 0) {
                // YOU CAN PUT CODE HERE TO STOP YOUR PLAYER FROM MOVING
            }
        }
        // A-Button
        else if (gamepad.buttonA == element) {
            if (gamepad.buttonA.value != 0) {
                print("Controller: \(index), A-Button Pressed!")
                jump()
            }
        }
        // B-Button // EXIT button
        else if (gamepad.buttonB == element) {
            if (gamepad.buttonB.value != 0) {
                print("Controller: \(index), B-Button Pressed!")
                
            }
        }
        else if (gamepad.buttonY == element) {
            if (gamepad.buttonY.value != 0) {
                print("Controller: \(index), Y-Button Pressed!")
            }
        }
        else if (gamepad.buttonX == element) {
            if (gamepad.buttonX.value != 0) {
                print("Controller: \(index), X-Button Pressed!")
            }
        }
    }
    
}
