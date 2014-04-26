package io.arkeus.mine.game.board {
	import io.axel.Ax;
	import io.axel.AxU;
	import io.axel.base.AxGroup;
	import io.axel.sprite.AxSprite;

	public class Block extends AxSprite {
		public static const SIZE:uint = 20;
		public static const SPEED:uint = 20;
		
		public var type:uint = BlockType.DIRT;
		public var cleared:Boolean = false;
		public var marked:Boolean = false;
		public var above:Block;
		
		public function Block(x:uint, y:uint, type:Number = NaN) {
			super(x, y);
			this.type = isNaN(type) ? BlockType.random() : type;
			
			var color:uint;
			switch (this.type) {
				case BlockType.DIRT: color = 0xffa26327; break;
				case BlockType.STONE: color = 0xff8d8d8d; break;
				case BlockType.FIRE: color = 0xffe91d1d; break;
				case BlockType.WATER: color = 0xff1d95e9; break;
				case BlockType.EARTH: color = 0xff50c31d; break;
				case BlockType.AIR: color = 0xfff2eb2f; break;
			}
			create(SIZE, SIZE, color);
//			velocity.a = AxU.rand(90, 270);
//			zoomIn();
//			centerOrigin();
		}
		
		private function zoomIn():void {
			effects.grow(Math.random() * 0.5 + 0.5, 2, 2, zoomOut);
		}
		
		private function zoomOut():void {
			effects.grow(Math.random() * 0.5 + 0.5, 0.5, 0.5, zoomIn);
		}
		
		override public function update():void {
			if (marked) {
				cleared = true;
				alpha -= Ax.dt;
				if (alpha <= 0) {
					destroy();
					(parent as AxGroup).remove(this);
				}
			}
			super.update();
		}
		
		public function get tx():uint {
			return x / SIZE;
		}
		
		public function get ty():uint {
			return (y + AxU.EPSILON) / SIZE;
		}
		
		public function get placeholder():Boolean {
			return type == BlockType.PLACEHOLDER;
		}
		
		public function get matchable():Boolean {
			return velocity.y == 0 && !cleared;
		}
		
		public function clear():void {
			marked = true;
		}
	}
}
