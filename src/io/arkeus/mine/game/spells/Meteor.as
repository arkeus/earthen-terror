package io.arkeus.mine.game.spells {
	import io.arkeus.mine.assets.Resource;
	import io.arkeus.mine.util.Registry;
	import io.axel.particle.AxParticleSystem;
	import io.axel.render.AxBlendMode;
	import io.axel.sprite.AxSprite;

	public class Meteor extends AxSprite {
		public static const SPEED:uint = 300;
		
		private var tx:int;
		private var ty:int;
		
		private var particleCounter:uint = 0;
		
		public function Meteor(tx:uint, ty:uint) {
			super(tx + 200, ty - 300, Resource.METEOR);
			
			this.tx = tx - width / 2;
			this.ty = ty - height / 2;
			blend = AxBlendMode.TRANSPARENT_TEXTURE;
			
			var direction:Number = Math.atan2(this.ty - this.y, this.tx - this.x);
			velocity.x = Math.cos(direction) * SPEED;
			velocity.y = Math.sin(direction) * SPEED;
			velocity.a = 720;
			centerOrigin();
		}
		
		override public function update():void {
			if (velocity.x != 0) {
				particleCounter++;
				if (particleCounter % 2 == 0) {
					AxParticleSystem.emit("meteor", center.x + parentOffset.x, center.y + parentOffset.y);
				}
				if (x < tx && y > ty) {
					Registry.board.meteor(tx, ty);
					blend = AxBlendMode.BLEND;
					velocity.zero();
					effects.fadeOut(0.5);
					effects.grow(0.5, 8, 8, function():void {
						destroy();
					});
				}
			}
			
			super.update();
		}
	}
}
