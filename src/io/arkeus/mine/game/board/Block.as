package io.arkeus.mine.game.board {
	import io.arkeus.mine.assets.Resource;
	import io.arkeus.mine.game.GameState;
	import io.arkeus.mine.util.Registry;
	import io.axel.Ax;
	import io.axel.AxU;
	import io.axel.base.AxGroup;
	import io.axel.render.AxBlendMode;
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
		private static var jar:AxSprite;
		private static var bar:AxSprite;
		
		public var hpm:Number = 100;
		public var hp:int = 100;

		public function Block(tx:uint, ty:uint, type:Number = NaN) {
			super(tx * SIZE, ty * SIZE, Resource.BLOCKS, SIZE, SIZE);
			this.type = isNaN(type) ? BlockType.random() : type;
			setType(this.type);
//			velocity.a = AxU.rand(90, 270);
//			zoomIn();
			centerOrigin();

			text = new AxText(0, 0, null, "");
			
			if (jar == null) {
				jar = new AxSprite(0, 0, Resource.JAR);
				jar.blend = AxBlendMode.TRANSPARENT_TEXTURE;
				bar = new AxSprite(0, 0, Resource.HEALTH);
				jar.noScroll();
				bar.noScroll();
			}
			
			animations.frameHeight = 10;
		}
		
		public function setType(type:uint):void {
			this.type = type;
			if (type < 10) {
				show(type);
			} else {
				switch (type) {
					case BlockType.SLIME:
						animations.add("enemy", [6, 7, 6, 8], 6);
					break;
				}
				animations.play("enemy");
			}
			if (type == BlockType.PLACEHOLDER) {
				visible = false;
			}
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
				return;
			}

			if (marked) {
				cleared = true;
				alpha -= Ax.dt * 1;
				if (alpha <= 0 && solid) {
					solid = false;
					var self:Block = this;
					timers.add(0.5, function():void {
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
			
			if (enemy && hp <= 0) {
				explode();
			}
			
			if (globalY < Board.TOP) {
//				Ax.states.change(new GameState);
			}

			super.update();
		}

		override public function draw():void {
			if (above != null && above.y < y - 19.5 && above.y > y - 20.5) {
				above.y = y - 20;
			}
			
//			if (inactive) {
//				var size:uint = 282 - (y + parentOffset.y);
//				load(Resource.BLOCKS, Block.SIZE, size, size);
//			}

			super.draw();
			if (enemy) {
				jar.x = x + parentOffset.x;
				jar.y = y + parentOffset.y;
				jar.draw();
				if (hp > 0) {
					bar.x = jar.x + 6;
					bar.y = jar.y + 17;
					bar.scale.x = hp / hpm;
					bar.draw();
				}
			}			
			
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
			if (!exists) {
				return;
			}
			destroy();
			(parent as AxGroup).remove(this);
		}
		
		public function get enemy():Boolean {
			return type >= 10 && type < 90;
		}
	}
}
