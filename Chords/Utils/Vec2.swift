import CoreGraphics

public typealias VecComponent = SignedNumeric

public struct Vec2<T: VecComponent>: CustomStringConvertible {
	public let x: T
	public let y: T
	public var asTuple: (x: T, y: T) { return (x: x, y: y) }
	public var xInverted: Vec2<T> { return Vec2(x: -x, y: y) }
	public var yInverted: Vec2<T> { return Vec2(x: x, y: -y) }
	public var description: String { return "(\(x), \(y))" }
	
	public init(x: T = 0, y: T = 0) {
		self.x = x
		self.y = y
	}
	
	public init(both value: T) {
		x = value
		y = value
	}
	
	public static func +(lhs: Vec2<T>, rhs: Vec2<T>) -> Vec2<T> {
		return Vec2(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
	}
	
	public static func -(lhs: Vec2<T>, rhs: Vec2<T>) -> Vec2<T> {
		return Vec2(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
	}
	
	public static func *(lhs: Vec2<T>, rhs: Vec2<T>) -> Vec2<T> {
		return Vec2(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
	}
	
	public static func *(lhs: Vec2<T>, rhs: T) -> Vec2<T> {
		return Vec2(x: lhs.x * rhs, y: lhs.y * rhs)
	}
	
	public prefix static func -(operand: Vec2<T>) -> Vec2<T> {
		return Vec2(x: -operand.x, y: -operand.y)
	}
	
	public func dot(other: Vec2<T>) -> T {
		return (x * other.x) + (y * other.y)
	}
	
	public func map<R: VecComponent>(mapper: (T) -> R) -> Vec2<R> {
		return Vec2<R>(x: mapper(x), y: mapper(y))
	}
	
	public func with(x newX: T) -> Vec2<T> {
		return Vec2(x: newX, y: y)
	}
	
	public func with(y newY: T) -> Vec2<T> {
		return Vec2(x: x, y: newY)
	}
}

extension Vec2 where T: BinaryFloatingPoint {
	public var length: T { return ((x * x) + (y * y)).squareRoot() }
	public var floored: Vec2<Int> { return Vec2<Int>(x: Int(x.rounded(.down)), y: Int(y.rounded(.down))) }
}

extension Vec2 where T == Int {
	public var asDouble: Vec2<Double> { return map { Double($0) } }
}

extension Vec2 where T == Double {
    public var asPoint: CGPoint { return CGPoint(x: x, y: y) }
    public var asSize: CGSize { return CGSize(width: x, height: y) }
    public var asVector: CGVector { return CGVector(dx: x, dy: y) }
    
    public init(from point: CGPoint) {
        x = Double(point.x)
        y = Double(point.y)
    }
}
