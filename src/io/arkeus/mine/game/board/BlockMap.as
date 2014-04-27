package io.arkeus.mine.game.board {
	import io.axel.AxU;

	public class BlockMap {
		public var map:Object;
		
		public function BlockMap() {
			this.map = {};
		}
		
		public function set(x:uint, y:uint, block:Block):void {
			map[x + "_" + y] = block;
		}
		
		public function get(x:uint, y:uint):Block {
			return map[x + "_" + y];
		}
		
		public function random():Block {
			var keys:Array = [];
			for (var key:String in map) {
				if (map[key].lockable) {
					keys.push(key);
				}
			}
			return map[keys[AxU.rand(0, keys.length - 1)]];
		}
	}
}
