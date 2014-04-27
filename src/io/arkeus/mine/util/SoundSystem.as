package io.arkeus.mine.util {
	import io.axel.Ax;
	import io.axel.sound.AxSound;

	public class SoundSystem {
		public static const VOLUME:Number = 0.5;

		public static var music:AxSound;
		public static var musicClass:Class;

		private static var sounds:Object = {};
		private static var initialized:Boolean = false;

		public static function playMusic(klass:Class):void {
			// todo maybe
		}

		public static function play(soundName:String):void {
			if (sounds[soundName] == null || Ax.sound.muted) {
				return;
			}
			(sounds[soundName] as SfxrSynth).play();
		}

		public static function create(soundName:String, parameters:String):void {
			if (Ax.sound.muted) {
				return;
			}
			var sound:SfxrSynth = new SfxrSynth;
			sound.params.setSettingsString(parameters);
			sound.cacheSound();
			sounds[soundName] = sound;
		}

		public static function initialize():void {
			if (initialized) {
				return;
			}
		}
	}
}
