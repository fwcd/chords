import SpriteKit

struct GuitarChordRenderer: ChordRenderer {
	private let width: Int
	private let height: Int
	private let gutterHeight: Double
	private let padding: Double
	private let fgColor: SKColor
	private let fretboard: GuitarFretboard
	private let minFrets: Int
	
	init(
		width: Int = 300,
		height: Int = 400,
		gutterHeight: Double = 10,
		padding: Double = 20,
		fgColor: SKColor = .white,
		fretboard: GuitarFretboard = GuitarFretboard(),
		minFrets: Int = 7
	) {
		self.width = width
		self.height = height
		self.gutterHeight = gutterHeight
		self.padding = padding
		self.fgColor = fgColor
		self.fretboard = fretboard
		self.minFrets = minFrets
	}
	
	func render(chord: Chord) throws -> SKNode {
        let node = SKNode()
        let guitarChord = try GuitarChord(from: chord, on: fretboard)
        let fretCount = max(minFrets, guitarChord.maxFret + 1)
        let stringCount = fretboard.stringCount

        let innerWidth = Double(width) - (padding * 2)
        let innerHeight = (Double(height) - (padding * 2)) - gutterHeight
        let stringSpacing = innerWidth / Double(stringCount - 1)
        let fretSpacing = innerHeight / Double(fretCount - 1)
        let dotRadius = fretSpacing * 0.4
        let topLeft = Vec2(x: -innerWidth / 2, y: innerHeight / 2)
        
        let gutterNode = SKShapeNode(rect: CGRect(origin: (topLeft - Vec2(y: gutterHeight)).asPoint, size: CGSize(width: innerWidth, height: gutterHeight)))
        gutterNode.fillColor = fgColor
        node.addChild(gutterNode)
        
        for stringIndex in 0..<stringCount {
            let position = topLeft + Vec2(x: stringSpacing * Double(stringIndex))
            let stringNode = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: position.asPoint)
            path.addLine(to: (position - Vec2(y: innerHeight)).asPoint)
            stringNode.strokeColor = fgColor
            stringNode.path = path
            node.addChild(stringNode)
        }

        for fretIndex in 0..<fretCount {
            let position = topLeft - Vec2(y: fretSpacing * Double(fretIndex))
            let fretNode = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: position.asPoint)
            path.addLine(to: (position + Vec2(x: innerWidth)).asPoint)
            fretNode.strokeColor = fgColor
            fretNode.path = path
            node.addChild(fretNode)
        }

        for dot in guitarChord.dots {
            let dotX = Double(dot.guitarString) * stringSpacing
            let dotNode: SKShapeNode
            let radius = Vec2(both: dotRadius)
            let diameter = radius * 2
            
            if dot.fret > 0 {
                let position = topLeft + Vec2(x: dotX, y: -(Double(dot.fret - 1) + 0.5) * fretSpacing)
                dotNode = SKShapeNode(ellipseIn: CGRect(origin: (position - radius).asPoint, size: diameter.asSize))
                dotNode.fillColor = fgColor
            } else {
                let position = topLeft + Vec2(x: dotX, y: gutterHeight + dotRadius)
                dotNode = SKShapeNode(ellipseIn: CGRect(origin: (position - radius).asPoint, size: diameter.asSize))
                dotNode.strokeColor = fgColor
                dotNode.fillColor = .clear
            }
            
            node.addChild(dotNode)
        }

        return node
	}
}
