package io.arkeus.mine.game {
	import flash.utils.getTimer;
	
	import io.arkeus.mine.assets.Resource;
	import io.arkeus.mine.game.board.Board;
	import io.arkeus.mine.util.Registry;
	import io.axel.Ax;
	import io.axel.sprite.AxParallaxSprite;
	import io.axel.sprite.AxSprite;
	import io.axel.state.AxState;

	public class GameState extends AxState {
		public var background:AxParallaxSprite;
		public var frame:AxSprite;
		public var board:Board;
		public var start:int = -1;
		public var end:int = 1;
		public var ended:Boolean = false;
		public var difficulty:uint;
		public var score:int;

		public function GameState(difficulty:uint = 0) {
			this.difficulty = difficulty;
			this.score = 0;
		}

		override public function create():void {
			Registry.game = this;
			noScroll();

			add(background = new AxParallaxSprite(0, 0, Resource.BACKGROUND));
			background.alpha = 0.5;
			background.scroll.x = background.scroll.y = 1;
			add(frame = new AxSprite(0, 0, Resource.FRAME));
			frame.alpha = 0.7;
			frame.noScroll();
			add(board = new Board());
		}

		override public function update():void {
//			if (Ax.keys.pressed(AxKey.ESCAPE)) {
//				Ax.states.change(new GameState);
//			} else if (Ax.keys.pressed(AxKey.Z)) {
//				Ax.states.change(new GameState(board.copy));
//			}
			if (start == -1) {
				start = getTimer();
			}
			if (!ended) {
				end = getTimer();
			}

			Ax.camera.x += Ax.dt * 10;
			Ax.camera.y += Ax.dt * 10;
			super.update();
		}
		
		public function get level():uint {
			return Math.ceil((end - start) / 20000);
		}
	}
}
