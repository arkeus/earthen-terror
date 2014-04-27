package io.arkeus.mine.util {
	import io.axel.Ax;
	import io.axel.input.AxKey;
	import io.axel.sprite.AxSprite;
	import io.axel.state.AxState;

	public class SpriteState extends AxState {
		private var graphic:Class;
		private var state:AxState;
		private var sprite:AxSprite;
		private var started:Boolean = false;
		private var counter:Number = 2;
		
		public function SpriteState(graphic:Class, state:AxState) {
			this.graphic = graphic;
			this.state = state;
		}
		
		override public function create():void {
			noScroll();
			
			add(sprite = new AxSprite(0, 0, graphic));
			//sprite.alpha = 0;
//			sprite.effects.fadeIn(1, 1, function():void {
//				started = true;
//			});
			started = true;
		}
		
		override public function update():void {
			if (started) {
				counter -= Ax.dt;
				if (counter <= 0) {
//					sprite.effects.fadeOut(1, 0, function():void {
//						callback();
//					});
					if (Ax.keys.pressed(AxKey.ANY)) {
						started = false;
						Ax.camera.fadeOut(1, 0xff000000, function():void {
							Ax.states.change(state);
							Ax.camera.fadeIn(1);
						});
					}
				}
			}
			super.update();
		}
	}
}
