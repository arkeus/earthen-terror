package io.axel.sound {
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import io.axel.Ax;

	/**
	 * A sound object. For simple use cases, this class will be completely managed by Axel. However,
	 * whenever you play a sound or music you will get the instance of this class returned to you in
	 * order to do more advanced effects.
	 */
	public class AxSound {
		/** The internal flash sound class. */
		public var soundClass:Class;
		/** The internal flash sound object. */
		public var sound:Sound;
		/** The internal flash sound channel. */
		public var soundChannel:SoundChannel;
		/** The internal flash sound transform. */
		public var soundTransform:SoundTransform;

		/**
		 * The sound manager this sound belongs to.
		 */
		public var manager:AxAudioManager;
		/**
		 * The requested volume of the sound, between 0 and 1. The current volume can be accessed through the
		 * volume property, which will be 0 if the sound is muted. This will always contained the requested
		 * volume, even when muted.
		 * @default 1
		 */
		public var requestedVolume:Number;
		/**
		 * The number of times this sound should loop. 0 means no looping.
		 */
		public var loops:uint;
		/**
		 * The time (in ms) of how far into the sound it should start playing. If looped, it will loop to this
		 * point in the song.
		 * @default 0
		 */
		public var start:Number;
		/**
		 * The amount the volume should change per frame.
		 */
		public var deltaVolume:Number;
		/**
		 * The target volume.
		 */
		public var targetVolume:Number;
		/**
		 * The panning of the sound between -1 (left) and 1 (right). 0 means balanced in the middle. The current
		 * panning can be accessed through the panning property. This will always contain the originally requested
		 * panning.
		 * @default 0
		 */
		public var requestedPanning:Number;
		/**
		 * The amount the pan should change per frame.
		 */
		public var deltaPan:Number;
		/**
		 * The target pan value.
		 */
		public var targetPan:Number;
		/**
		 * Whether or not the sound should be destroyed when the current fade completes.
		 */
		public var destroyOnComplete:Boolean;
		
		/**
		 * Creates the sound. This should always be done before initialize is called. Any allocation
		 * that needs to happen should happen here, and pooling will handle calling initialize to
		 * allow reuse of this object.
		 * 
		 * @param sound The embedded sound file to play.
		 */
		public function create(soundClass:Class):void {
			this.soundClass = soundClass;
			this.soundTransform = new SoundTransform(0, 0);
			this.sound = new soundClass();
		}
		
		/**
		 * Initializes a sound object, but does not start playing the sound.
		 *
		 * @param manager the Manager this sound belongs to.
		 * @param volumeLevel The volume to play the sound at.
		 * @param loops The number of loops this sound should do.
		 * @param start The time (in ms) of how far into the sound it should start playing.
		 * @param panning The panning of the sound between -1 (left) and 1 (right). 0 means balanced in the middle.
		 */
		public function initialize(manager:AxAudioManager, volumeLevel:Number = 1, loops:uint = 0, start:Number = 0, panning:Number = 0):void {
			this.manager = manager;
			this.requestedVolume = volumeLevel;
			this.loops = loops;
			this.start = start;
			this.requestedPanning = panning;
			this.soundTransform.volume = volumeLevel;
			this.soundTransform.pan = panning;
			this.soundTransform = this.soundTransform;
			this.targetVolume = requestedVolume;
			this.targetPan = requestedPanning;
			this.deltaPan = 0;
			this.deltaVolume = 0;
		}

		/**
		 * Plays the sound. If loop is true, will repeat once it reaches the end. This method does nothing if
		 * you have no sound card or you run out of available sound channels. The maximum amount of sounds you
		 * can play at once is 32.
		 *
		 * @return
		 */
		public function play():void {
			soundChannel = sound.play(start, loops, soundTransform);
			if (soundChannel == null) {
				destroy();
				return;
			}
			soundChannel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
		}

		/**
		 * Sets the volume to a new value.
		 * 
		 * @param volumeLevel The new volume to set.
		 */
		public function set volume(volumeLevel:Number):void {
			if (volumeLevel < 0 || volumeLevel > 1) {
				throw new ArgumentError("Volume to set must be between 0 and 1.");
			}
			soundTransform.volume = volumeLevel;
			if (soundChannel != null) {
				soundChannel.soundTransform = soundTransform;
			}
		}

		/**
		 * Gets the current volume.
		 * 
		 * @return The volume.
		 */
		public function get volume():Number {
			return soundTransform.volume;
		}

		/**
		 * Immediately mutes the sound by setting the volume to 0.
		 * 
		 * @return This sound.
		 */
		public function mute():AxSound {
			volume = 0;
			return this;
		}

		/**
		 * Immediately unmutes the sound by setting the volume to the originally requested volume.
		 * 
		 * @return This sound.
		 */
		public function unmute():AxSound {
			volume = requestedVolume;
			return this;
		}

		/**
		 * Fades the sound out over the passed duration. By default, destroys the sound when the fade out
		 * completes, but can be overriden by passing false to destroyOnComplete.
		 * 
		 * @param duration The duration of the fade effect.
		 * @param destroyOnComplete Whether or not to destroy the sound at the end.
		 * @return This sound.
		 */
		public function fadeOut(duration:Number, destroyOnComplete:Boolean = true):AxSound {
			this.destroyOnComplete = destroyOnComplete;
			return fade(duration, 0);
		}

		/**
		 * Fades in the sound over the passed duration.
		 * 
		 * @param duration The duration of the fade effect.
		 * @return This sound.
		 */
		public function fadeIn(duration:Number):AxSound {
			return fade(duration, 1);
		}

		/**
		 * Fades the sound to the specified volume over the passed duration.
		 * 
		 * @param duration The duration of the fade effect.
		 * @param targetVolume The target volume to fade to (between 0 and 1).
		 * @return This sound.
		 */
		public function fade(duration:Number, targetVolume:Number):AxSound {
			if (targetVolume < 0 || targetVolume > 1) {
				throw new ArgumentError("Volume to fade to must be between 0 and 1.");
			}
			this.targetVolume = targetVolume;
			deltaVolume = (targetVolume - volume) / duration * Ax.dt;
			if (deltaVolume == 0 && targetVolume == 0 && destroyOnComplete) {
				destroy();
			}
			return this;
		}

		/**
		 * Immediately sets the panning of this sound to the passed value.
		 * 
		 * @param panValue The new panning value to use (between -1 and 1).
		 */
		public function set panning(panValue:Number):void {
			if (panValue < -1 || panValue > 1) {
				throw new ArgumentError("Panning value to set must be between -1 and 1.");
			}
			soundTransform.pan = panValue;
			if (soundChannel != null) {
				soundChannel.soundTransform = soundTransform;
			}
		}

		/**
		 * Gets the current panning value.
		 * 
		 * @return The current panning.
		 */
		public function get panning():Number {
			return soundTransform.pan;
		}

		/**
		 * Pans the sound to the left side over the passed duration.
		 * 
		 * @param duration The duration of the panning effect.
		 * @return This sound.
		 */
		public function panLeft(duration:Number):AxSound {
			return pan(duration, -1);
		}

		/**
		 * Pans the sound to the right side over the passed duration.
		 * 
		 * @param duration The duration of the panning effect.
		 * @return This sound.
		 */
		public function panRight(duration:Number):AxSound {
			return pan(duration, 1);
		}
		
		/**
		 * Pans the sound to the center over the passed duration.
		 * 
		 * @param duration The duration of the panning effect.
		 * @return This sound.
		 */
		public function panCenter(duration:Number):AxSound {
			return pan(duration, 0);
		}

		/**
		 * Pans the sound to the targetPan value over the passed duration.
		 * 
		 * @param duration The duration of the panning effect.
		 * @param targetPan The target pan to fade to.
		 * @return This sound.
		 */
		public function pan(duration:Number, targetPan:Number):AxSound {
			if (targetPan < -1 || targetPan > 1) {
				throw new ArgumentError("Panning to fade to must be between -1 and 1.");
			}
			this.targetPan = targetPan;
			deltaPan = (targetPan - panning) / duration * Ax.dt;
			return this;
		}

		/**
		 * Logic to update the sound each frame.
		 */
		public function update():void {
			if (deltaVolume != 0) {
				var newVolume:Number = volume + deltaVolume;
				if ((deltaVolume > 0 && newVolume >= targetVolume) || (deltaVolume < 0 && newVolume <= targetVolume)) {
					if (targetVolume == 0 && destroyOnComplete) {
						destroy();
						return;
					} else {
						volume = targetVolume;
						deltaVolume = 0;
					}
				} else {
					volume = newVolume;
				}
			}

			if (deltaPan != 0) {
				var newPan:Number = panning + deltaPan;
				if ((deltaPan > 0 && newPan >= targetPan) || (deltaPan < 0 && newPan <= targetPan)) {
					panning = targetPan;
					deltaPan = 0;
				} else {
					panning = newPan;
				}
			}
		}

		/**
		 * Sound completion callback.
		 *
		 * @param event The sound completion event.
		 */
		private function onSoundComplete(event:Event):void {
			destroy();
		}

		/**
		 * Destroys the sound, removing it from the manager. Keeps objects around as the manager
		 * uses a pool of these objects, and we don't want to have to reallocate them.
		 */
		public function destroy():void {
			if (soundChannel != null) {
				soundChannel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
				soundChannel.stop();
				soundChannel = null;
			}
			manager.remove(this);
		}
	}
}
