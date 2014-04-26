package io.arkeus.mine.game.board {
	import io.arkeus.mine.game.GameState;
	import io.arkeus.mine.util.Registry;
	import io.axel.Ax;
	import io.axel.AxU;
	import io.axel.base.AxGroup;
	import io.axel.sprite.AxSprite;
	import io.axel.text.AxText;

	public class Block extends AxSprite {
		public static const SIZE:uint = 20;
		public static const SPEED:uint = 250;

		public var type:uint = BlockType.DIRT;
		public var cleared:Boolean = false;
		public var marked:Boolean = false;
		public var falling:Boolean = false;
		public var above:Block;
		public var swapping:Boolean = false;
		public var inactive:Boolean = false;

		public var ptx:uint;
		public var pty:uint;

		private var text:AxText;

		public function Block(tx:uint, ty:uint, type:Number = NaN) {
			super(tx * SIZE, ty * SIZE);
			this.type = isNaN(type) ? BlockType.random() : type;

			var color:uint;
			switch (this.type) {
				case BlockType.DIRT:  {
					color = 0xffa26327;
					break;
				}
				case BlockType.STONE:  {
					color = 0xff8d8d8d;
					break;
				}
				case BlockType.FIRE:  {
					color = 0xffe91d1d;
					break;
				}
				case BlockType.WATER:  {
					color = 0xff1d95e9;
					break;
				}
				case BlockType.EARTH:  {
					color = 0xff50c31d;
					break;
				}
				case BlockType.AIR:  {
					color = 0xfff2eb2f;
					break;
				}
				case BlockType.PLACEHOLDER:  {
					color = 0x00000000;
					break;
				}
			}
			create(SIZE, SIZE, color);
//			velocity.a = AxU.rand(90, 270);
//			zoomIn();
			centerOrigin();

			text = new AxText(0, 0, null, "");
		}

		private function zoomIn():void {
			effects.grow(Math.random() * 0.5 + 0.5, 2, 2, zoomOut);
		}

		private function zoomOut():void {
			effects.grow(Math.random() * 0.5 + 0.5, 0.5, 0.5, zoomIn);
		}

		override public function update():void {
			if (!swapping && placeholder) {
				explode();
			}

			if (marked) {
				cleared = true;
				alpha -= Ax.dt * 1;
				if (alpha <= 0 && solid) {
					solid = false;
					var self:Block = this;
					timers.add(0.25, function():void {
						self.explode();
					});
					return;
				}
			} else {
				if (globalY > Board.BOTTOM - 20) {
					inactive = true;
					alpha = 0.3;
				} else {
					inactive = false;
					alpha = 1;
				}
			}

			if (falling) {
				pvelocity.y = velocity.y = SPEED;
			}
			
			if (globalY < Board.TOP) {
				Ax.states.change(new GameState);
			}

			super.update();
		}

		override public function draw():void {
			if (above != null && above.y < y - 19.5 && above.y > y - 20.5) {
				above.y = y - 20;
			}

			super.draw();
			text.x = x + parentOffset.x;
			text.y = y + parentOffset.y;
			text.text = y.toFixed(1);
			//text.draw();
		}

		public function get tx():uint {
			return swapping ? ptx : (x + AxU.EPSILON) / SIZE;
		}

		public function get ty():uint {
			return swapping ? pty : (y + AxU.EPSILON) / SIZE;
		}

		public function get placeholder():Boolean {
			return type == BlockType.PLACEHOLDER;
		}

		public function get matchable():Boolean {
			return velocity.y == 0 && (!cleared || alpha < 0.1) && !swapping && !inactive;
		}

		public function clear():void {
			marked = true;
		}

		public function fall():void {
			falling = true;
		}

		public function land(below:Block):void {
			velocity.y = 0;
			if (below != null) {
				y = below.y - SIZE;
			} else {
				y = (Registry.board.height - 1) * SIZE;
			}
			falling = false;
		}

		public function explode():void {
			destroy();
			(parent as AxGroup).remove(this);
		}
	}
}
