import SpriteKit

protocol ChordRenderer {
	func render(chord: Chord) throws -> SKNode
}
