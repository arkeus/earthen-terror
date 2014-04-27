package io.arkeus.mine.map {
	import io.arkeus.mine.assets.Resource;
	import io.arkeus.mine.title.TitleState;
	import io.arkeus.mine.util.Registry;
	import io.axel.Ax;
	import io.axel.input.AxKey;
	import io.axel.sprite.AxSprite;
	import io.axel.state.AxState;
	import io.axel.text.AxText;

	public class MapState extends AxState {
		private var map:AxSprite;
		private var levels:LevelSet;
		private var text:AxText;
		private var done:Boolean = false;

		override public function create():void {
			noScroll();
			add(map = new AxSprite(0, 0, Resource.MAP));
			add(levels = new LevelSet);
			add(text = new AxText(0, 8, null, "Choose A Digsite", Ax.viewWidth, "center"));
		}

		override public function update():void {
			if (!done) {
				if (Ax.keys.pressed(AxKey.Z) || Ax.keys.pressed(AxKey.W) || Ax.keys.pressed(AxKey.SPACE) || Ax.keys.pressed(AxKey.ENTER)) {
					if (levels.cursor.selected.index == 1 || Registry.progress[levels.cursor.selected.index - 2] > 0) {
						Ax.states.push(new LevelState(levels.cursor.selected));
					}
				} else if (Ax.keys.pressed(AxKey.ESCAPE) || Ax.keys.pressed(AxKey.X)) {
					done = true;
					Ax.camera.fadeOut(1, 0xff000000, function():void {
						Ax.states.change(new TitleState);
						Ax.camera.fadeIn(1);
					});
				}
			}

			super.update();
		}
	}
}
