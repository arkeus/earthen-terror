package io.arkeus.mine.game.spells {
	import io.arkeus.mine.assets.Resource;
	import io.arkeus.mine.util.Registry;
	import io.arkeus.mine.util.SoundSystem;
	import io.axel.Ax;
	import io.axel.particle.AxParticleSystem;
	import io.axel.render.AxBlendMode;
	import io.axel.sprite.AxSprite;

	public class Lightning extends AxSprite {
		public static const SPEED:uint = 900;
		
		private var tx:int;
		private var ty:int;
		
		private var particleCounter:uint = 0;
		
		public function Lightning(tx:uint, ty:uint) {
			super(tx - 17, ty - 900, Resource.LIGHTNING);
			
			velocity.y = SPEED;
			blend = AxBlendMode.TRANSPARENT_TEXTURE;
			
			Ax.camera.flash(0.05, 0x77ffffff);
			SoundSystem.play("lightning-flash");
			timers.add(0.2, function():void {
				Ax.camera.flash(0.05, 0x77ffffff);
				SoundSystem.play("lightning-flash");
				timers.add(0.3, function():void {
					SoundSystem.play("lightning");
				});
			});
		}
		
		override public function update():void {
			Registry.board.lightning(center.x, y + height);
			particleCounter++;
			if (particleCounter % 2 == 0) {
				AxParticleSystem.emit("lightning", center.x + parentOffset.x, y + height + parentOffset.y);
			}
			
			if (globalY > 300) {
				destroy();
			}
			
			super.update();
		}
	}
}
