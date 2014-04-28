package io.arkeus.mine.game.board {
	import io.arkeus.mine.assets.Resource;
	import io.arkeus.mine.game.spells.Blade;
	import io.arkeus.mine.util.Difficulty;
	import io.arkeus.mine.util.Registry;
	import io.arkeus.mine.util.SoundSystem;
	import io.axel.Ax;
	import io.axel.AxU;
	import io.axel.base.AxGroup;
	import io.axel.particle.AxParticleSystem;
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
		public var locked:Boolean = false;
		public var comboable:int = 0;
		public var comboEnabled:Boolean = false;
		
		public var douse:int = 0;
		public var avalanche:int = 0;
		public var lightning:int = 0;
		public var meteor:int = 0;

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

			switch (Registry.game.difficulty) {
				case Difficulty.EASY:  {
					hpm = hp = 150 + 8 * Registry.game.level;
					break;
				}
				case Difficulty.NORMAL:  {
					hpm = hp = 200 + 12 * Registry.game.level;
					break;
				}
				case Difficulty.HARD:  {
					hpm = hp = 200 + 16 * Registry.game.level;
					break;
				}
			}

			if (enemy) {
				timers.add(attackTimer, attack, 0);
			}

			animations.frameHeight = 10;
		}

		public function setType(type:uint):void {
			this.type = type;
			if (type < 10) {
				show(type);
//				if (Math.random() < 0.05) {
//					lock();
//				} else {
//					unlock();
//				}
			} else {
				switch (type) {
					case BlockType.SLIME:  {
						animations.add("enemy", [12, 13, 12, 14], 8);
						break;
					}
					case BlockType.SQUID:  {
						animations.add("enemy", [15, 16, 15, 17], 8);
						break;
					}
					case BlockType.RABBIT:  {
						animations.add("enemy", [18, 19, 18, 20], 8);
						break;
					}
					case BlockType.LION:  {
						animations.add("enemy", [21, 22, 21, 23], 8);
						break;
					}
					case BlockType.MOUSE:  {
						animations.add("enemy", [24, 25, 24, 26], 8);
						break;
					}
				}
				animations.play("enemy");
			}
			if (type == BlockType.PLACEHOLDER) {
				visible = false;
			}
		}

		public function lock():void {
			if (enemy) {
				return;
			}
			show(type + 6);
			locked = true;
		}

		public function unlock():void {
			if (enemy) {
				return;
			}
			show(type);
			locked = false;
			AxParticleSystem.emit("unlock", x + parentOffset.x, y + parentOffset.y);
		}

		private function zoomIn():void {
			effects.grow(Math.random() * 0.5 + 0.5, 2, 2, zoomOut);
		}

		private function zoomOut():void {
			effects.grow(Math.random() * 0.5 + 0.5, 0.5, 0.5, zoomIn);
		}

		override public function update():void {
			if (!Registry.game.ended) {
//				scale.x = comboEnabled ? 0.5 : 1;
				
				comboable--;
				douse--;
				avalanche--;
				meteor--;
				lightning--;
				
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
	//					alpha = 0.3;
						color.hex = 0xff333333;
					} else {
						inactive = false;
	//					alpha = 1;
						color.hex = 0xffffffff;
					}
				}
	
				if (falling) {
					pvelocity.y = velocity.y = SPEED;
				}
	
				if (enemy && hp <= 0) {
					Registry.game.enemies++;
					AxParticleSystem.emit("glass", x + parentOffset.x, y + parentOffset.y);
					SoundSystem.play("glass");
					explode();
				}
	
				if (globalY < Board.TOP && loseable) {
					Registry.game.lose();
				}
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
				if (Registry.game.ended) {
					jar.blend = AxBlendMode.BLEND;
				} else {
					jar.blend = AxBlendMode.TRANSPARENT_TEXTURE;
				}
				jar.x = x + parentOffset.x;
				jar.y = y + parentOffset.y;
				jar.alpha = alpha;
				jar.draw();
				if (hp > 0) {
					bar.x = jar.x + 6;
					bar.y = jar.y + 17;
					bar.scale.x = hp / hpm;
					bar.alpha = alpha;
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
		
		public function get loseable():Boolean {
			return velocity.y == 0 && !cleared && !swapping && !inactive;
		}

		public function get swapable():Boolean {
			return velocity.y == 0 && (!cleared || alpha < 0.1) && !swapping && !inactive && !locked;
		}

		public function get fallable():Boolean {
			return velocity.y == 0 && (!cleared || alpha < 0.1) && !swapping && !inactive;
		}

		public function get lockable():Boolean {
			return !cleared && !swapping && !inactive && !locked;
		}

		public function clear():void {
			if (locked) {
				unlock();
			} else {
				if (comboable > 0) {
					trace("COMBO");
				}
				marked = true;
				velocity.a = 180;
			}
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
			if (comboEnabled && below != null && below.loseable) {
				comboable = 10;
			}
			comboEnabled = false;
			if (below != null && (below.cleared || below.comboEnabled)) {
				comboEnabled = true;
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

		private function get attackTimer():Number {
			switch (type) {
				case BlockType.SLIME:  {
					return Math.max(2, 6 - Registry.game.level * 0.1);
					break;
				}
				case BlockType.SQUID:  {
					return Math.max(8, 12 - Registry.game.level * 0.1);
					break;
				}
				case BlockType.RABBIT:  {
					return Math.max(8, 12 - Registry.game.level * 0.1);
					break;
				}
				case BlockType.LION:  {
					return Math.max(4, 8 - Registry.game.level * 0.1);
					break;
				}
				case BlockType.MOUSE:  {
					return Math.max(4, 9 - Registry.game.level * 0.1);
					break;
				}
			}
			return 999;
		}

		private function attack():void {
			if (inactive) {
				return;
			}

			var block:Block, x:int, y:int;

			switch (type) {
				case BlockType.SLIME:  {
					Registry.board.spells.add(new Blade(this.x, this.y, Registry.board.map.random()));
					SoundSystem.play("blade-shoot");
					break;
				}
				case BlockType.SQUID:  {
					for (x = tx - 1; x <= tx + 1; x++) {
						for (y = ty - 1; y <= ty + 1; y++) {
							block = Registry.board.map.get(x, y);
							if (block != null && block.lockable) {
								Registry.board.spells.add(new Blade(this.x, this.y, block));
							}
						}
					}
					SoundSystem.play("blade-shoot");

					break;
				}
				case BlockType.RABBIT:  {
					for (x = 0; x < Board.WIDTH; x++) {
						block = Registry.board.map.get(x, ty);
						if (block != null && block.lockable) {
							Registry.board.spells.add(new Blade(this.x, this.y, block));
						}
					}
					SoundSystem.play("blade-shoot");
					break;
				}
				case BlockType.LION:  {
					for (x = tx - 1; x <= tx + 1; x++) {
						block = Registry.board.map.get(x, ty);
						if (block != null && block.lockable) {
							Registry.board.spells.add(new Blade(this.x, this.y, block));
						}
					}
					SoundSystem.play("blade-shoot");
					
					break;
				}
				case BlockType.MOUSE:  {
					Registry.board.spells.add(new Blade(this.x, this.y, Registry.board.map.random()));
					Registry.board.spells.add(new Blade(this.x, this.y, Registry.board.map.random()));
					SoundSystem.play("blade-shoot");
					break;
				}
			}
		}
	}
}
