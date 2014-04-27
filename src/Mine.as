package {
	import io.arkeus.mine.game.GameState;
	import io.arkeus.mine.map.MapState;
	import io.arkeus.mine.title.TitleState;
	import io.arkeus.mine.util.Config;
	import io.axel.Ax;
	
	[SWF(width = "520", height = "600", backgroundColor = "#000000")]
//	[SWF(width = "260", height = "300", backgroundColor = "#000000")]
	
	public class Mine extends Ax {
		public function Mine() {
			super(TitleState, Config.WIDTH * Config.ZOOM, Config.HEIGHT * Config.ZOOM, Config.ZOOM);
//			super(TitleState, Config.WIDTH, Config.HEIGHT, 1);
		}
		
		override public function create():void {
			Ax.background.hex = 0xff000000;
			Ax.pauseState = null;
			Ax.debuggerEnabled = true;
		}
	}
}
