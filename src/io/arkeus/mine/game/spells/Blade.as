package io.arkeus.mine.game.spells {
	import io.arkeus.mine.assets.Resource;
	import io.arkeus.mine.game.board.Block;
	import io.arkeus.mine.util.SoundSystem;
	import io.axel.render.AxBlendMode;
	import io.axel.sprite.AxSprite;

	public class Blade extends AxSprite {
		public static const SPEED:uint = 200;
		
		private var target:Block;

		public function Blade(x:uint, y:uint, target:Block) {
			super(x, y, Resource.BLADE);
			velocity.a = 720;
			blend = AxBlendMode.TRANSPARENT_TEXTURE;

			var direction:Number = Math.atan2(target.y - y, target.x - x);
			velocity.x = Math.cos(direction) * SPEED;
			velocity.y = Math.sin(direction) * SPEED;
			
			this.target = target;
		}
		
		override public function update():void {
			var dx:int = target.x - x;
			var dy:int = target.y - y;
			if (Math.abs(dx) < 4 && Math.abs(dy) < 4) {
				if (target.exists) {
					target.lock();
					SoundSystem.play("blade-hit");
				}
				destroy();
			}
			super.update();
		}
	}
}
