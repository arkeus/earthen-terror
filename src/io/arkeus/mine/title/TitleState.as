package io.arkeus.mine.title {
	import io.arkeus.mine.assets.Resource;
	import io.arkeus.mine.map.MapState;
	import io.arkeus.mine.util.Registry;
	import io.arkeus.mine.util.SoundSystem;
	import io.arkeus.mine.util.SpriteState;
	import io.axel.Ax;
	import io.axel.input.AxKey;
	import io.axel.render.AxBlendMode;
	import io.axel.sprite.AxParallaxSprite;
	import io.axel.sprite.AxSprite;
	import io.axel.state.AxState;
	import io.axel.text.AxText;

	public class TitleState extends AxState {
		public var background:AxParallaxSprite;
		public var title:AxSprite;
		public var sound:AxText;
		public var music:AxText;
		public var reset:AxText;

		private var done:Boolean = false;

		override public function create():void {
			noScroll();

			Ax.camera.fadeIn(0.5);
			Ax.music.fadeOut(1).fadeIn(MusicTitle);

			add(background = new AxParallaxSprite(0, 0, Resource.BACKGROUND));
			background.alpha = 0.25;
			background.scroll.x = background.scroll.y = 1;
			add(title = new AxSprite(0, 0, Resource.TITLE));
			title.blend = AxBlendMode.TRANSPARENT_TEXTURE;

			add(sound = new AxText(0, 205, null, "", Ax.viewWidth, "center"));
			add(music = new AxText(0, 219, null, "", Ax.viewWidth, "center"));

			var hasSave:Boolean = Registry.hasSave();
			if (hasSave) {
				add(reset = new AxText(0, 233, null, "Press @[ff0000]R + P@[] to reset all data", Ax.viewWidth, "center"));
			}

			sound.alpha = music.alpha = reset.alpha = 0.5;

			if (Ax.mode != "Hardware Mode") {
				add(new AxText(40, 30, null, "@[ff0000]Warning: Your setup does not support hardware rendering. Performance may be terrible.", Ax.viewWidth - 80, "center"));
			}
		}

		override public function update():void {
			if (!done) {
				if (Ax.keys.pressed(AxKey.SPACE) && Ax.camera.sprite.alpha <= 0) {
					done = true;
					SoundSystem.play("select");
					Ax.camera.fadeOut(1, 0xff000000, function():void {
						if (Registry.story) {
							Ax.states.change(new MapState);
						} else {
							Ax.states.change(new SpriteState(Resource.STORY, new SpriteState(Resource.QUICKSTART, new MapState)));
							Registry.story = true;
							Registry.quickstart = true;
						}
						Ax.camera.fadeIn(1);
					});
				} else if (Ax.keys.pressed(AxKey.M) && Ax.camera.sprite.alpha <= 0) {
					Ax.music.toggleMute();
					SoundSystem.play("move");
				} else if (Ax.keys.pressed(AxKey.S) && Ax.camera.sprite.alpha <= 0) {
					Ax.sound.toggleMute();
					SoundSystem.play("move");
				} else if (Ax.keys.held(AxKey.R) && Ax.keys.held(AxKey.P) && Ax.camera.sprite.alpha <= 0) {
					Registry.reset();
					reset.destroy();
				}
			}

			if (Ax.sound.muted) {
				sound.text = "Sound: @[ff0000]Off@[] (@[ff0000]S to turn on)";
			} else {
				sound.text = "Sound: @[00ff00]On@[] (@[00ff00]S to turn off)";
			}

			if (Ax.music.muted) {
				music.text = "Music: @[ff0000]Off@[] (@[ff0000]M to turn on)";
			} else {
				music.text = "Music: @[00ff00]On@[] (@[00ff00]M to turn off)";
			}

			Ax.camera.x += Ax.dt * 10;
			Ax.camera.y += Ax.dt * 10;
			super.update();

			//Ax.states.change(new GameState(0, 0, new Level(0, 0, 1, "test", 1, [])));
		}
	}
}
