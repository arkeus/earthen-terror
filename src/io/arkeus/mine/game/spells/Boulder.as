package io.arkeus.mine.game.spells {
	import io.arkeus.mine.assets.Resource;
	import io.arkeus.mine.util.Registry;
	import io.axel.Ax;
	import io.axel.particle.AxParticleSystem;
	import io.axel.sprite.AxSprite;

	public class Boulder extends AxSprite {
		public static const SPEED:uint = 300;
		
		private var tx:int;
		private var ty:int;
		
		public function Boulder(tx:int, ty:int) {
			super(tx, ty, Resource.BOULDER);
			
			velocity.y = SPEED;
			centerOrigin();
			//blend = AxBlendMode.TRANSPARENT_TEXTURE;
			
			Ax.camera.shake(1, 3);
		}
		
		override public function update():void {
			if (solid) {
				if (Registry.board.boulder(center.x, y + height)) {
					AxParticleSystem.emit("avalanche", center.x + parentOffset.x, center.y + parentOffset.y);
					velocity.zero();
					effects.fadeOut(1, 0, destroy);
					velocity.y = -200;
					gravity = 600;
					solid = false;
				}
			}
			
			if (globalY > 300) {
				destroy();
			}
			
			super.update();
		}
	}
}
