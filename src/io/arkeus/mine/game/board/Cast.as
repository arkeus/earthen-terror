package io.arkeus.mine.game.board {
	import io.arkeus.mine.assets.Resource;
	import io.axel.sprite.AxSprite;

	public class Cast extends AxSprite {
		private static const SPEED:uint = 100;
		
		private var type:uint;
		private var homing:Boolean = false;
		private var target:Block;
		
		public function Cast(x:int, y:int, type:uint, target:Block) {
			super(x, y, Resource.CASTS, Block.SIZE, Block.SIZE);
			
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
				var direction:Number = Math.atan2(target.y - y, target.x - x);
				velocity.x = Math.cos(direction) * SPEED * 3;
				velocity.y = Math.sin(direction) * SPEED * 3;
			}
			
			var dx:int = target.x - x;
			var dy:int = target.y - y;
			if (Math.abs(dx) < 4 && Math.abs(dy) < 4) {
				if (target.exists) {
					target.hp -= 20;
				}
				destroy();
			}
			
			super.update();
		}
	}
}
