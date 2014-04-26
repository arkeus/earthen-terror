package io.arkeus.mine.game {
	import io.arkeus.mine.game.board.Board;
	import io.arkeus.mine.util.Registry;
	import io.axel.Ax;
	import io.axel.input.AxKey;
	import io.axel.state.AxState;

	public class GameState extends AxState {
		public var board:Board;
		public var blah:Array;
		
		public function GameState(blah:Array = null) {
			this.blah = blah;
		}
		
		override public function create():void {
			Registry.game = this;
			add(board = new Board(50, 50, blah));
		}
		
		override public function update():void {
			if (Ax.keys.pressed(AxKey.ESCAPE)) {
				Ax.states.change(new GameState);
			} else if (Ax.keys.pressed(AxKey.Z)) {
				Ax.states.change(new GameState(board.copy));
			}
			super.update();
		}
	}
}
