package io.arkeus.mine.game.board {
	import io.axel.sprite.AxSprite;

	public class Cursor extends AxSprite {
		public var tx:uint;
		public var ty:uint;
		
		public function Cursor(tx:uint, ty:uint) {
			super(tx * Block.SIZE, ty * Block.SIZE);
			
			create(Block.SIZE * 2, Block.SIZE, 0x99000000);
		}
		
		public function move(dx:int, dy:int):void {
			if (tx + dx >= 0 && tx + dx < Board.WIDTH - 1) {
				tx += dx;
			}
			if (ty + dy >= 0 && ty + dy < Board.HEIGHT) {
				ty += dy;
			}
			
			x = tx * Block.SIZE;
			y = ty * Block.SIZE;
		}
	}
}
