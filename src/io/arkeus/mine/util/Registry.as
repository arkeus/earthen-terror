package io.arkeus.mine.util {
	import flash.net.SharedObject;
	
	import io.arkeus.mine.game.GameState;
	import io.arkeus.mine.game.board.Board;
	import io.arkeus.mine.ui.UI;
	import io.axel.Ax;

	public class Registry {
		public static var game:GameState;
		public static var board:Board;
		public static var ui:UI;
		
		public static var difficulty:int = -1;
		public static var progress:Array = [0, 0, 0, 0, 0];
		public static var story:Boolean = false;
		public static var quickstart:Boolean = false;
		
		private static var so:SharedObject;
		
		public static function initialize():void {
			so = SharedObject.getLocal("earthen-terror");
		}
		
		public static function save():void {
			try {
				so.data.difficulty = difficulty;
				so.data.progress = progress;
				so.data.story = story;
				so.data.quickstart = quickstart;
				so.data.musicMuted = Ax.music.muted;
				so.data.soundMuted = Ax.sound.muted;
			} catch (error:Error) {
				trace("Error saving", error);
			}
		}
		
		public static function reset():void {
			difficulty = -1;
			progress = [0, 0, 0, 0, 0];
			story = false;
			quickstart = false;
			save();
		}
		
		public static function flush():void {
			so.flush();
		}
		
		public static function load():void {
			try {
				if (so.data.story != true) {
					trace("No data to load, skipping");
					return;
				}
				difficulty = so.data.difficulty;
				progress = so.data.progress;
				story = so.data.story;
				quickstart = so.data.quickstart;
				if (so.data.musicMuted) {
					Ax.music.mute();
				}
				if (so.data.soundMuted) {
					Ax.sound.mute();
				}
			} catch (error:Error) {
				trace("Error loading", error);
				throw error;
			}
		}
		
		public static function hasSave():Boolean {
			return so.data && so.data.story == true;
		}
	}
}
