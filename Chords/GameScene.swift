//
//  GameScene.swift
//  Chords
//
//  Created by Fredrik on 4/7/19.
//  Copyright © 2019 Fredrik. All rights reserved.
//

import SpriteKit
import GameplayKit
import Foundation

class GameScene: SKScene {
    private var label: SKLabelNode?
    private var lastPress: Date?
    private var chordNode: SKNode?
    private let chordRenderer: ChordRenderer = GuitarChordRenderer()
    
    override func didMove(to view: SKView) {
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//centerLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
//        if let spinnyNode = self.spinnyNode {
//            spinnyNode.lineWidth = 2.5
//
//            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
//            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
//                                              SKAction.fadeOut(withDuration: 0.5),
//                                              SKAction.removeFromParent()]))
//        }
    }
    
    private func update(chord rawChord: String) {
        label?.text = rawChord
        
        if let chord = try? Chord(of: rawChord) {
            if let previousChordNode = chordNode {
                removeChildren(in: [previousChordNode])
            }
            chordNode = try? chordRenderer.render(chord: chord)
            if let newChordNode = chordNode {
                addChild(newChordNode)
            }
        }
    }
    
    override func keyDown(with event: NSEvent) {
        let secondsSinceLastPress = -(lastPress?.timeIntervalSinceNow ?? -10000)
        
        if event.keyCode == 51 { // backspace
            if let oldText = label?.text {
                update(chord: String(oldText.dropLast()))
            }
        } else if let chars = event.characters {
            if secondsSinceLastPress > 1 {
                update(chord: chars)
            } else if let oldText = label?.text {
                update(chord: oldText + chars)
            }
        }
        
        lastPress = Date()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
