package io.arkeus.mine.game.board {
	import io.arkeus.mine.assets.Resource;
	import io.arkeus.mine.util.Registry;
	import io.axel.sprite.AxSprite;

	public class Cast extends AxSprite {
		private static const SPEED:uint = 100;

		private var type:uint;
		private var homing:Boolean = false;
		private var target:Block;

		public function Cast(x:int, y:int, type:uint, target:Block) {
			super(x, y, Resource.CASTS, Block.SIZE, Block.SIZE);
			noScroll();
			this.type = type;

			show(type - 2);
			velocity.a = 180;

			var direction:Number = Math.random() * Math.PI * 2;
			velocity.x = Math.cos(direction) * SPEED;
			velocity.y = Math.sin(direction) * SPEED;
			drag.x = 100;
			drag.y = 100;

			this.target = target;

			effects.grow(1, 0.75, 0.75);
		}

		override public function update():void {
			if (!homing && Math.abs(velocity.x) < 2 && Math.abs(velocity.y) < 2) {
				homing = true;
				drag.x = drag.y = 0;
				velocity.a = 0;
			}

			if (homing) {
				if (target != null && target.hp <= 0) {
					target = null
				}
				
				var direction:Number;
				var tx:int, ty:int;
				if (target != null) {
					tx = target.x;
					ty = target.y;
				} else {
					switch (type) {
						case BlockType.FIRE:  {
							tx = 155;
							ty = 187;
							break;
						}
						case BlockType.EARTH:  {
							tx = 155;
							ty = 212;
							break;
						}
						case BlockType.WATER:  {
							tx = 155;
							ty = 237;
							break;
						}
						case BlockType.AIR:  {
							tx = 155;
							ty = 262;
							break;
						}
					}
					tx -= parentOffset.x;
					ty -= parentOffset.y;
				}

				direction = Math.atan2(ty - y, tx - x);
				velocity.x = Math.cos(direction) * SPEED * 3;
				velocity.y = Math.sin(direction) * SPEED * 3;

				var dx:int = tx - x;
				var dy:int = ty - y;
				if (Math.abs(dx) < 4 && Math.abs(dy) < 4) {
					if (target != null) {
						target.hp -= 20;
					} else {
						switch (type) {
							case BlockType.FIRE:  {
								Registry.ui.fire++;
								break;
							}
							case BlockType.EARTH:  {
								Registry.ui.earth++;
								break;
							}
							case BlockType.WATER:  {
								Registry.ui.water++;
								break;
							}
							case BlockType.AIR:  {
								Registry.ui.air++;
								break;
							}
						}
					}
					destroy();
				}
			}

			super.update();
		}
	}
}
