fileprivate struct UnoctavedNote: Hashable {
	let letter: NoteLetter
	let accidental: Accidental
}

/// Maps semitones to unoctaved notes on the common twelve-tone scale.
/// Corresponds to the individual keys to on the piano.
fileprivate let twelveToneOctave: [[UnoctavedNote]] = [
	[UnoctavedNote(letter: .c, accidental: .none)],
	[UnoctavedNote(letter: .c, accidental: .sharp), UnoctavedNote(letter: .d, accidental: .flat)],
	[UnoctavedNote(letter: .d, accidental: .none)],
	[UnoctavedNote(letter: .d, accidental: .sharp), UnoctavedNote(letter: .e, accidental: .flat)],
	[UnoctavedNote(letter: .e, accidental: .none)],
	[UnoctavedNote(letter: .f, accidental: .none)],
	[UnoctavedNote(letter: .f, accidental: .sharp), UnoctavedNote(letter: .g, accidental: .flat)],
	[UnoctavedNote(letter: .g, accidental: .none)],
	[UnoctavedNote(letter: .g, accidental: .sharp), UnoctavedNote(letter: .a, accidental: .flat)],
	[UnoctavedNote(letter: .a, accidental: .none)],
	[UnoctavedNote(letter: .a, accidental: .sharp), UnoctavedNote(letter: .b, accidental: .flat)],
	[UnoctavedNote(letter: .b, accidental: .none)]
]

/**
 * Matches a single musical note.
 *
 * 1. group: letter
 * 2. group: accidental (optional)
 * 3. group: octave (optional)
 */
fileprivate let notePattern = try! Regex(from: "([a-zA-Z])([b#]?)(\\d+)?")

struct Note: CustomStringConvertible {
	let letter: NoteLetter
	let octave: Int? // The octave in scientific pitch notation
	let accidental: Accidental
	let semitone: Int // Semitones in an octave
	var description: String { return "\("\(letter)".uppercased())\(accidental.rawValue)\(octave.map { String($0) } ?? "")" }
	
	private init(letter: NoteLetter, accidental: Accidental, semitone: Int, octave: Int? = nil) {
		self.letter = letter
		self.octave = octave
		self.accidental = accidental
		self.semitone = semitone.clockModulo(twelveToneOctave.count)
	}
	
	init(of str: String) throws {
		guard let parsed = notePattern.firstGroups(in: str) else { throw NoteError.invalidNote(str) }
		guard let letter = NoteLetter.of(parsed[1]) else { throw NoteError.invalidNoteLetter(parsed[1]) }
		let accidental = Accidental(rawValue: parsed[2]) ?? .none
		let octave = parsed[3].nilIfEmpty.flatMap { Int($0) }
		guard let (semitone, _) = twelveToneOctave.enumerated().first(where: { $0.1.contains(UnoctavedNote(letter: letter, accidental: accidental)) }) else { throw NoteError.notInTwelveToneOctave(str) }
		
		self.init(letter: letter, accidental: accidental, semitone: semitone, octave: octave)
	}
	
	static func +(lhs: Note, rhs: NoteInterval) -> Note {
		let octavesDelta: Int
		
		if rhs.degrees >= 0 {
			octavesDelta = rhs.degrees / 7
		} else {
			octavesDelta = (rhs.degrees - 6) / 7
		}
		
		let nextSemitone = (lhs.semitone + rhs.semitones).clockModulo(twelveToneOctave.count)
		let nextLetter = lhs.letter + rhs.degrees
		let candidates = twelveToneOctave[nextSemitone]
		guard let twelveToneNote = candidates.first(where: { $0.letter == nextLetter }) ?? candidates.first else {
			fatalError("Could not locate note with semitone \(nextSemitone) and letter \(nextLetter) in twelve-tone octave (from: \(lhs) with interval: \(rhs))")
		}
		
		return Note(letter: nextLetter, accidental: twelveToneNote.accidental, semitone: nextSemitone, octave: lhs.octave.map { $0 + octavesDelta })
	}
	
	static func -(lhs: Note, rhs: NoteInterval) -> Note {
		return lhs + (-rhs)
	}
	
	func matches(_ rhs: Note) -> Bool {
		return (semitone == rhs.semitone)
			&& (octave == nil || rhs.octave == nil || octave == rhs.octave)
	}
}
