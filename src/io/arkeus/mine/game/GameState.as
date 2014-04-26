package io.arkeus.mine.game {
	import io.arkeus.mine.assets.Resource;
	import io.arkeus.mine.game.board.Board;
	import io.arkeus.mine.ui.UI;
	import io.arkeus.mine.util.Registry;
	import io.axel.Ax;
	import io.axel.input.AxKey;
	import io.axel.sprite.AxParallaxSprite;
	import io.axel.sprite.AxSprite;
	import io.axel.state.AxState;

	public class GameState extends AxState {
		public var background:AxParallaxSprite;
		public var frame:AxSprite;
		public var board:Board;
		public var blah:Array;
		public var ui:UI;

		public function GameState(blah:Array = null) {
			this.blah = blah;
		}

		override public function create():void {
			Registry.game = this;

			add(background = new AxParallaxSprite(0, 0, Resource.BACKGROUND));
			add(frame = new AxSprite(0, 0, Resource.FRAME));
			frame.noScroll();

			add(board = new Board(blah));

			add(ui = new UI);
		}

		override public function update():void {
			if (Ax.keys.pressed(AxKey.ESCAPE)) {
				Ax.states.change(new GameState);
			} else if (Ax.keys.pressed(AxKey.Z)) {
				Ax.states.change(new GameState(board.copy));
			}

			Ax.camera.x += Ax.dt * 10;
			Ax.camera.y += Ax.dt * 10;
			super.update();
		}
	}
}
