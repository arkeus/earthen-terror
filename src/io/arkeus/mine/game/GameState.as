package io.arkeus.mine.game {
	import io.arkeus.mine.game.board.Board;
	import io.axel.Ax;
	import io.axel.input.AxKey;
	import io.axel.state.AxState;

	public class GameState extends AxState {
		public var board:Board;
		
		override public function create():void {
			add(board = new Board(50, 50));
		}
		
		override public function update():void {
			if (Ax.keys.pressed(AxKey.ESCAPE)) {
				Ax.states.change(new GameState);
			}
			super.update();
		}
	}
}
