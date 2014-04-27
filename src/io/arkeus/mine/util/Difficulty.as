package io.arkeus.mine.util {
	public class Difficulty {
		public static const EASY:uint = 0;
		public static const NORMAL:uint = 1;
		public static const HARD:uint = 2;
		
		public static function toString(difficulty:uint):String {
			switch (difficulty) {
				case EASY: return "Easy";
				case NORMAL: return "Normal";
				case HARD: return "Hard";
			}
			throw new ArgumentError("Invalid difficulty value: " + difficulty);
		}
		
		public static function fromString(value:String):uint {
			switch (value) {
				case "Easy": return EASY;
				case "Normal": return NORMAL;
				case "Hard": return HARD;
			}
			throw new ArgumentError("Invalid difficulty string: " + value);
		}
	}
}
