package io.arkeus.mine.game.board {
	import io.arkeus.mine.assets.Resource;
	import io.arkeus.mine.util.Registry;
	import io.axel.sprite.AxSprite;

	public class Cursor extends AxSprite {
		public var tx:uint;
		public var ty:uint;
		
		public function Cursor(tx:uint, ty:uint) {
			super(tx * Block.SIZE - 3, ty * Block.SIZE - 3, Resource.CURSOR);
		}
		
		public function move(dx:int, dy:int):void {
			if (!visible) {
				return;
			}
			
			if (tx + dx >= 0 && tx + dx < Board.WIDTH - 1) {
				tx += dx;
			}
			if (ty + dy >= 0 && ty + dy < Registry.board.height - 1) {
				ty += dy;
			}
			
			x = tx * Block.SIZE - 3;
			y = ty * Block.SIZE - 3;
		}
	}
}
