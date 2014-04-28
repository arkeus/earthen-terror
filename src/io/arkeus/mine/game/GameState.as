package io.arkeus.mine.game {
	import io.arkeus.mine.assets.Resource;
	import io.arkeus.mine.game.board.Board;
	import io.arkeus.mine.game.end.LoseState;
	import io.arkeus.mine.game.end.PauseState;
	import io.arkeus.mine.game.end.WinState;
	import io.arkeus.mine.map.Level;
	import io.arkeus.mine.util.Difficulty;
	import io.arkeus.mine.util.Registry;
	import io.arkeus.mine.util.SoundSystem;
	import io.axel.Ax;
	import io.axel.input.AxKey;
	import io.axel.sprite.AxParallaxSprite;
	import io.axel.sprite.AxSprite;
	import io.axel.state.AxState;

	public class GameState extends AxState {
		public static const GOAL:uint = 0;
		public static const ENDLESS:uint = 1;

		public var background:AxParallaxSprite;
		public var frame:AxSprite;
		public var board:Board;
		public var time:Number;
		public var ended:Boolean = false;
		public var difficulty:uint;
		public var enemies:int;
		public var mode:uint;
		public var digsite:Level;
		public var goal:int;

		public function GameState(difficulty:uint = 0, mode:uint = 0, digsite:Level = null) {
			this.difficulty = difficulty;
			this.enemies = 0;
			this.time = 0;
			this.mode = mode;
			this.digsite = digsite;
			switch (difficulty) {
				case Difficulty.EASY:  {
					this.goal = digsite.baseGoal * 0.5;
					break;
				}
				case Difficulty.NORMAL:  {
					this.goal = digsite.baseGoal * 0.75;
					break;
				}
				case Difficulty.HARD:  {
					this.goal = digsite.baseGoal * 1;
					break;
				}
			}
		}

		override public function create():void {
			Registry.game = this;
			noScroll();
			Ax.music.fadeOut(1).fadeIn(MusicGame);

			add(background = new AxParallaxSprite(0, 0, Resource.BACKGROUND));
			background.alpha = 0.5;
			background.scroll.x = background.scroll.y = 1;
			add(frame = new AxSprite(0, 0, Resource.FRAME));
			frame.alpha = 0.7;
			frame.noScroll();
			add(board = new Board());
		}

		override public function update():void {
			if (!ended) {
				if (Ax.keys.pressed(AxKey.ESCAPE)) {
					SoundSystem.play("cancel");
					Ax.states.push(new PauseState);
				}
				if (mode == GOAL && enemies >= goal) {
					win();
				}
				time += Ax.dt;
			}

			Ax.camera.x += Ax.dt * 10;
			Ax.camera.y += Ax.dt * 10;
			super.update();
		}

		public function get level():uint {
			return Math.ceil(time / 20);
		}

		public function win():void {
			if (ended) {
				return;
			}

			Registry.save();
			ended = true;
			board.lose();
			timers.add(1, function():void {
				Ax.states.push(new WinState());
			});
		}

		public function lose():void {
			if (ended) {
				return;
			}

			Registry.save();
			SoundSystem.play("lose");
			ended = true;
			board.lose();
			timers.add(1, function():void {
				Ax.states.push(new LoseState());
			});
		}
	}
}
