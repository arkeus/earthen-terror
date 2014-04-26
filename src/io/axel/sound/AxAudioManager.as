package io.axel.sound {
	import io.axel.pool.AxPool;

	/**
	 * A manager used for playing and keeping track of audio. Used both for sounds and music.
	 */
	public class AxAudioManager {
		/** The list of currently active sounds. */
		public var sounds:Vector.<AxSound>;
		/** A mapping from sound class to list of cached sounds. */
		public var cache:Object;
		/** Whether or not this manager is muted. */
		public var muted:Boolean;
		/** The volume of this manager. */
		public var volume:Number;
		
		/**
		 * Creates a new audio manager.
		 */
		public function AxAudioManager() {
			this.sounds = new Vector.<AxSound>;
			this.cache = {};
			this.muted = false;
			this.volume = 1;
		}
		
		/**
		 * Each frame, updates all active sounds within the manager.
		 */
		public function update():void {
			for (var i:uint = 0; i < sounds.length; i++) {
				sounds[i].update();
			}
		}
		
		/**
		 * Mutes all sounds in this manager, and causes future sounds to play muted.
		 */
		public function mute():void {
			this.muted = true;
			for (var i:uint = 0; i < sounds.length; i++) {
				sounds[i].mute();
			}
		}
		
		/**
		 * Unmutes all sounds in this manager, and causes future sounds to play unmuted.
		 */
		public function unmute():void {
			this.muted = false;
			for (var i:uint = 0; i < sounds.length; i++) {
				sounds[i].unmute();
			}
		}
		
		/**
		 * Toggles the mute value. If currently muted, unmutes, and if not muted, mutes.
		 */
		public function toggleMute():void {
			muted ? unmute() : mute();
		}
		
		/**
		 * Plays a sound once.
		 * 
		 * @param soundFile The sound to play.
		 * @param volumeLevel The volume at which to play the sound.
		 * @param start The start position, in ms, in which to play the sound.
		 * @param pan The panning (from -1 to 1, where -1 is left, 0 is center, and 1 is right) to use.
		 * @return The newly created sound.
		 */
		public function play(soundFile:Class, volumeLevel:Number = 1, start:Number = 0, pan:Number = 0):AxSound {
			var soundObject:AxSound = create(soundFile, volumeLevel, 0, start, pan);
			soundObject.play();
			return soundObject;
		}
		
		/**
		 * Plays a sound on repeat (such as music). To stop, you can call stop or fadeOut on the manager in order to
		 * stop and fade out all sounds. Alternatively, you can save the returned AxSound and manually call fadeOut
		 * or destroy on it yourself.
		 * 
		 * @param soundFile The sound to repeat.
		 * @param volumeLevel The volume at which to play the sound.
		 * @param start The start position, in ms, in which to play the sound.
		 * @param pan The panning (from -1 to 1, where -1 is left, 0 is center, and 1 is right) to use.
		 * @return The newly created sound.
		 */
		public function repeat(soundFile:Class, volumeLevel:Number = 1, start:Number = 0, pan:Number = 0):AxSound {
			var soundObject:AxSound = create(soundFile, volumeLevel, int.MAX_VALUE, start, pan);
			soundObject.play();
			return soundObject;
		}
		
		/**
		 * Creates a new sound, but doesn't yet play it. You will need to call play() on the returned sound yourself.
		 * 
		 * @param soundFile The sound to create.
		 * @param volumeLevel The volume at which to play the sound.
		 * @param loops The number of times to repeat the sound.
		 * @param start The start position, in ms, in which to play the sound.
		 * @param pan The panning (from -1 to 1, where -1 is left, 0 is center, and 1 is right) to use.
		 * @return The newly created sound.
		 */
		public function create(soundFile:Class, volumeLevel:Number = 1, loops:uint = 0, start:Number = 0, pan:Number = 0):AxSound {
			var soundCache:AxPool = cache[soundFile];
			if (soundCache == null) {
				soundCache = new AxPool(AxSound, 0, function(sound:AxSound):void {
					sound.create(soundFile);
				});
				cache[soundFile] = soundCache;
			}
			
			var soundObject:AxSound = soundCache.remove();
			soundObject.initialize(this, volumeLevel * volume, loops, start, pan);
			if (muted) {
				soundObject.mute();
			}
			sounds.push(soundObject);
			return soundObject;
		}
		
		/**
		 * Fades out all sounds over the duration specified. If destroyOnComplete is set to true (the default), will
		 * clean up all the sounds automatically when they are done fading out.
		 * 
		 * @param duration Duration over which to fade out.
		 * @param destroyOnComplete Whether or not to automatically clean up the sounds when they finish fading.
		 * @return This manager.
		 */
		public function fadeOut(duration:Number = 1, destroyOnComplete:Boolean = true):AxAudioManager {
			for (var i:uint = 0; i < sounds.length; i++) {
				sounds[i].fadeOut(duration, destroyOnComplete);
			}
			return this;
		}
		
		/**
		 * Fades in a new sound over the duration specified. By default, will loop the song indefinitely, but can be
		 * changed by specifying a value for loops.
		 * 
		 * @param soundFile The sound or music to fade in.
		 * @param duration Duration over which to fade in.
		 * @param volumeLevel The volume at which to play the sound.
		 * @param loops The number of times to repeat the sound.
		 * @param start The start position, in ms, in which to play the sound.
		 * @param pan The panning (from -1 to 1, where -1 is left, 0 is center, and 1 is right) to use.
		 * @return This manager.
		 */
		public function fadeIn(soundFile:Class, duration:Number = 1, volumeLevel:Number = 1, loops:uint = int.MAX_VALUE, start:Number = 0, pan:Number = 0):AxSound {
			var soundObject:AxSound = create(soundFile, volumeLevel, loops, start, pan);
			if (!muted) {
				soundObject.fadeIn(duration);
			}
			soundObject.play();
			return soundObject;
		}
		
		/**
		 * Fades all sounds to pan to the left side over the specified duration.
		 * 
		 * @param duration Duration over which to pan.
		 * @return This manager.
		 */
		public function panLeft(duration:Number):AxAudioManager {
			for (var i:uint = 0; i < sounds.length; i++) {
				sounds[i].panLeft(duration);
			}
			return this;
		}
		
		/**
		 * Fades all sounds to pan to the right side over the specified duration.
		 * 
		 * @param duration Duration over which to pan.
		 * @return This manager.
		 */
		public function panRight(duration:Number):AxAudioManager {
			for (var i:uint = 0; i < sounds.length; i++) {
				sounds[i].panRight(duration);
			}
			return this;
		}
		
		/**
		 * Fades all sounds to pan to the center over the specified duration.
		 * 
		 * @param duration Duration over which to pan.
		 * @return This manager.
		 */
		public function panCenter(duration:Number):AxAudioManager {
			for (var i:uint = 0; i < sounds.length; i++) {
				sounds[i].panCenter(duration);
			}
			return this;
		}
		
		/**
		 * Removes a sound from the active sounds. If you specify for sounds not to be cleaned up automatically, you
		 * should manually remove them for performance reasons. If there are many sounds that are not cleaned up,
		 * performance will suffer. You can see how many sounds are "active" by checking the length of the sounds vector.
		 * 
		 * @param sound The AxSound object to remove.
		 */
		public function remove(sound:AxSound):void {
			var index:int = sounds.indexOf(sound);
			if (index >= 0) {
				sounds.splice(index, 1);
			}
			cache[sound.soundClass].add(sound);
		}
	}
}
