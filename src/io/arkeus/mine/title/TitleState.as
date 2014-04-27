package io.arkeus.mine.title {
	import io.arkeus.mine.assets.Resource;
	import io.arkeus.mine.game.GameState;
	import io.arkeus.mine.map.Level;
	import io.arkeus.mine.map.MapState;
	import io.axel.Ax;
	import io.axel.input.AxKey;
	import io.axel.render.AxBlendMode;
	import io.axel.sprite.AxParallaxSprite;
	import io.axel.sprite.AxSprite;
	import io.axel.state.AxState;

	public class TitleState extends AxState {
		public var background:AxParallaxSprite;
		public var title:AxSprite;
		
		private var done:Boolean = false;

		override public function create():void {
			noScroll();

			add(background = new AxParallaxSprite(0, 0, Resource.BACKGROUND));
			background.alpha = 0.25;
			background.scroll.x = background.scroll.y = 1;
			add(title = new AxSprite(0, 0, Resource.TITLE));
			title.blend = AxBlendMode.TRANSPARENT_TEXTURE;
		}

		override public function update():void {
			if (Ax.keys.pressed(AxKey.SPACE) && !done) {
				done = true;
				Ax.camera.fadeOut(1, 0xff000000, function():void {
					Ax.states.change(new MapState);
					Ax.camera.fadeIn(1);
				});
			}

			Ax.camera.x += Ax.dt * 10;
			Ax.camera.y += Ax.dt * 10;
			super.update();
			
			//Ax.states.change(new GameState(0, 0, new Level(0, 0, 1, "test", 1, [])));
		}
	}
}
