//
//  AppViewController.swift
//  Chords
//
//  Created by Fredrik on 4/7/19.
//  Copyright © 2019 Fredrik. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class AppViewController: NSViewController {
    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.skView {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
        }
    }
}

