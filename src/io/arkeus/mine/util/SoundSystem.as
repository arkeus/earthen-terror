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
			
			create("select", "1,,0.1531,,0.37,0.27,,0.28,,,,,,,,0.5054,,,1,,,,,0.4");
			create("move", "3,,0.0453,,0.1387,0.3452,,-0.5257,,,,,,,,,,,1,,,0.1842,,0.3");
			create("cancel", "0,,0.1924,,0.1639,0.4553,,-0.18,,,,,,0.3011,,,,,1,,,0.1815,,0.4");
			create("clear", "0,,0.1672,,0.58,0.24,,0.1799,,0.6653,0.595,,,0.5349,,,,,1,,,,,0.4");
			create("clear-2", "0,,0.1672,,0.58,0.33,,0.1799,,0.6653,0.595,,,0.5349,,,,,1,,,,,0.4");
			create("clear-3", "0,,0.1672,,0.58,0.42,,0.1799,,0.6653,0.595,,,0.5349,,,,,1,,,,,0.4");
			create("swap", "0,,0.1994,,0.2,0.2,,0.28,,,,,,0.1806,,,,,1,,,0.1,,0.4");
			create("lose", "1,,0.3668,,0.4023,0.2822,,-0.14,,,,,,,,,,,1,,,,,0.4");
			create("meteor-explode", "3,,0.3683,0.4114,0.2794,0.3929,,-0.3181,,,,,,,,,,,1,,,,,0.4");
			create("meteor-fall", "3,,0.2428,0.6366,0.9,0.45,,-0.1999,,,,0.7196,0.6518,,,,,,1,,,,,0.4");
			create("douse", "0,,0.29,,0.6,0.3884,,-0.12,,,,,,0.2846,,,,,0.641,,,,,0.4");
			create("lightning", "3,,0.1961,0.4611,0.64,0.1577,,0.0885,,,,,,,,0.3048,,,1,,,,,0.4");
			create("lightning-flash", "3,,0.1054,0.05,0.38,0.72,,-0.28,,,,,,,,,0.1954,-0.1226,1,,,,,0.4");
			create("avalanche", "3,,0.3651,0.6039,0.85,0.1744,,-0.04,0.1599,,,,,,,,-0.1443,-0.0011,1,,,,,0.25");
			create("meteor-fall", "3,,0.2428,0.6366,0.9,0.45,,-0.1999,,,,0.7196,0.6518,,,,,,1,,,,,0.4");
			create("meteor-fall", "3,,0.2428,0.6366,0.9,0.45,,-0.1999,,,,0.7196,0.6518,,,,,,1,,,,,0.4");
			create("meteor-fall", "3,,0.2428,0.6366,0.9,0.45,,-0.1999,,,,0.7196,0.6518,,,,,,1,,,,,0.4");
			create("blade-shoot", "3,,0.0678,,0.2076,0.3385,,-0.3834,,,,,,,,,,,1,,,0.2867,,0.4");
			create("blade-hit", "3,,0.0678,,0.34,0.57,,-0.3834,,,,,,,,,,,1,,,0.2867,,0.4");
			create("glass", "3,,0.3544,0.74,0.47,0.35,,-0.0999,0.06,,,,,,,,,,1,,,,,0.4");
		}
	}
}
