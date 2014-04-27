package io.arkeus.mine.game.board {
	import io.axel.AxU;

	public class BlockType {
		public static const STONE:uint = 0;
		public static const DIRT:uint = 1;
		public static const FIRE:uint = 2;
		public static const EARTH:uint = 3;
		public static const WATER:uint = 4;
		public static const AIR:uint = 5;
		
		public static const SLIME:uint = 10;
		public static const SQUID:uint = 11;
		public static const RABBIT:uint = 12;
		public static const LION:uint = 13;
		public static const MOUSE:uint = 14;
		
		public static const PLACEHOLDER:uint = 100;
		
		public static function random():uint {
			return AxU.rand(1, 5);
		}
	}
}
