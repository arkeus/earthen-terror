package io.arkeus.mine.game.end {
	import io.arkeus.mine.assets.Resource;
	import io.arkeus.mine.map.MapState;
	import io.arkeus.mine.util.Registry;
	import io.axel.Ax;
	import io.axel.input.AxKey;
	import io.axel.sprite.AxSprite;
	import io.axel.state.AxState;

	public class PauseState extends AxState {
		private var lose:AxSprite;
		private var faded:Boolean = true;
		private var done:Boolean = false;

		override public function create():void {
			noScroll();

			add(lose = new AxSprite(0, 0, Resource.PAUSE));
		}

		override public function update():void {
			if (faded && !done) {
				if (Ax.keys.pressed(AxKey.SPACE)) {
					done = true;
					Ax.camera.fadeOut(0.5, 0xff000000, function():void {
						Ax.states.pop();
						Ax.states.change(new MapState(Registry.game.digsite.index));
						Ax.camera.fadeIn(0.5);
					});
				} else if (Ax.keys.pressed(AxKey.ESCAPE)) {
					done = true;
					Ax.states.pop();
				}
			}
			super.update();
		}
	}
}
