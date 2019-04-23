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
            if let newNode = try? chordRenderer.render(chord: chord) {
                let previousChordNode = chordNode
                
                addChild(newNode)
                chordNode = newNode
                
                if let previousNode = previousChordNode {
                    transition(from: previousNode, to: newNode)
                }
            }
        }
    }
    
    private func transition(from previousNode: SKNode, to nextNode: SKNode) {
        var remainingNext = Set(nextNode.children)
        let transitionDelay = 1.0

        for oldChild in previousNode.children {
            if let closest = remainingNext
                    .filter({ distance(between: oldChild, and: $0) > 0 })
                    .min(by: { distance(between: oldChild, and: $0) < distance(between: oldChild, and: $1) }) {
                remainingNext.remove(closest)
                closest.isHidden = true
                
                oldChild.run(.move(by: delta(between: oldChild, and: closest, in: previousNode).asVector, duration: transitionDelay)) {
                    closest.isHidden = false
                    oldChild.removeFromParent()
                }
            } else {
                oldChild.removeFromParent()
            }
        }
        
        previousNode.run(.sequence([
            .wait(forDuration: transitionDelay * 2),
            .removeFromParent()
        ]))
    }
    
    private func delta(between a: SKNode, and b: SKNode, in node: SKNode) -> Vec2<Double> {
        return Vec2(from: b.convert(pathPosition(of: b), to: node)) - Vec2(from: a.convert(pathPosition(of: a), to: node))
    }
    
    private func distance(between a: SKNode, and b: SKNode) -> Double {
        return delta(between: a, and: b, in: self).length
    }
    
    private func pathPosition(of node: SKNode) -> CGPoint {
        if let shapeNode = node as? SKShapeNode {
            if let box = shapeNode.path?.boundingBox {
                return CGPoint(x: box.origin.x + (box.width / 2), y: box.origin.y + (box.height / 2))
            }
        }
        return node.position
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
