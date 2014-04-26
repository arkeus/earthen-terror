package io.arkeus.mine.game.board {
	import io.axel.AxU;

	public class BlockType {
		public static const DIRT:uint = 0;
		public static const STONE:uint = 1;
		public static const FIRE:uint = 2;
		public static const WATER:uint = 3;
		public static const EARTH:uint = 4;
		public static const AIR:uint = 5;
		
		public static const PLACEHOLDER:uint = 100;
		
		public static function random():uint {
			return AxU.rand(0, 5);
		}
	}
}
