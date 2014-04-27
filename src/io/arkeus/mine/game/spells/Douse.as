package io.arkeus.mine.game.spells {
	import io.arkeus.mine.assets.Resource;
	import io.arkeus.mine.util.Registry;
	import io.axel.Ax;
	import io.axel.particle.AxParticleSystem;
	import io.axel.render.AxBlendMode;
	import io.axel.sprite.AxSprite;

	public class Douse extends AxSprite {
		public static const SPEED:uint = 300;
		
		private var tx:int;
		private var ty:int;
		
		private var particleCounter:uint = 0;
		
		public function Douse(tx:int, ty:int) {
			super(tx, ty, Resource.DOUSE);
			
			velocity.x = SPEED;
			centerOrigin();
			blend = AxBlendMode.TRANSPARENT_TEXTURE;
			
			Ax.camera.shake(0.2, 3);
		}
		
		override public function update():void {
			if (solid) {
				Registry.board.lightning(center.x, y + height);
				particleCounter++;
				if (particleCounter % 2 == 0) {
					AxParticleSystem.emit("douse", center.x + parentOffset.x, center.y + parentOffset.y - 2);
				}
				
				Registry.board.douse(x + width, center.y);
				if (x > 400) {
					destroy();
				}
			}
			
			super.update();
		}
	}
}
