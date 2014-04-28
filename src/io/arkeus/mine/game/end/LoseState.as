package io.arkeus.mine.game.end {
	import io.arkeus.mine.assets.Resource;
	import io.arkeus.mine.game.GameState;
	import io.arkeus.mine.map.MapState;
	import io.arkeus.mine.util.Registry;
	import io.axel.Ax;
	import io.axel.input.AxKey;
	import io.axel.sprite.AxSprite;
	import io.axel.state.AxState;

	public class LoseState extends AxState {
		private var lose:AxSprite;
		private var faded:Boolean = false;
		private var done:Boolean = false;
		
		override public function create():void {
			noScroll();
			
			add(lose = new AxSprite(0, 0, Resource.LOSE));
			lose.alpha = 0;
			lose.effects.fadeIn(0.5, 1, function():void {
				faded = true;
			});
		}
		
		override public function update():void {
			if (faded && !done) {
				if (Ax.keys.pressed(AxKey.SPACE)) {
					done = true;
					Ax.camera.fadeOut(0.5, 0xff000000, function():void {
						Ax.states.pop();
						Ax.states.change(new GameState(Registry.game.difficulty, Registry.game.mode, Registry.game.digsite));
						Ax.camera.fadeIn(0.5);
					});
				} else if (Ax.keys.pressed(AxKey.ESCAPE)) {
					done = true;
					Ax.camera.fadeOut(0.5, 0xff000000, function():void {
						Registry.flush();
						Ax.states.pop();
						Ax.states.change(new MapState(Registry.game.digsite.index));
						Ax.camera.fadeIn(0.5);
					});
				}
			}
			super.update();
		}
	}
}
