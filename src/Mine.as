package {
	import io.arkeus.mine.game.GameState;
	import io.arkeus.mine.util.Config;
	import io.axel.Ax;
	
	[SWF(width = "520", height = "600", backgroundColor = "#000000")]
	public class Mine extends Ax {
		public function Mine() {
			super(GameState, Config.WIDTH * Config.ZOOM, Config.HEIGHT * Config.ZOOM, Config.ZOOM);
		}
		
		override public function create():void {
			Ax.background.hex = 0xff333333;
		}
	}
}
