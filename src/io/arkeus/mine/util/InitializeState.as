package io.arkeus.mine.util {
	import io.arkeus.mine.title.TitleState;
	import io.axel.Ax;
	import io.axel.state.AxState;

	public class InitializeState extends AxState {
		private var counter:uint = 0;
		private var done:Boolean = false;
		private var title:TitleState;
		
		override public function create():void {
			
		}
		
		override public function update():void {
			if (counter++ > 20 && !done) {
				Ax.logger.log("NOW");
				done = true;
				title = new TitleState;
				Ax.camera.fadeOut(0.25, 0xff000000, function():void {
					Ax.states.change(title);
					Ax.camera.fadeIn(1, function():void { Ax.logger.log("DONE"); });
				});
			}
			
			super.update();
		}
	}
}
