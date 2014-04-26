package io.arkeus.mine.game.board {
	public class BlockMap {
		private var map:Object;
		
		public function BlockMap() {
			this.map = {};
		}
		
		public function set(x:uint, y:uint, block:Block):void {
			map[x + "_" + y] = block;
		}
		
		public function get(x:uint, y:uint):Block {
			return map[x + "_" + y];
		}
	}
}
