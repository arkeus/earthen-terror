package io.arkeus.mine.map {
	import io.arkeus.mine.assets.Resource;
	import io.arkeus.mine.util.SoundSystem;
	import io.axel.sprite.AxSprite;

	public class LevelCursor extends AxSprite {
		public var selected:Level;
		
		public function LevelCursor() {
			super(0, 0, Resource.MAP_CURSOR);
			velocity.a = 180;
		}
		
		public function select(level:Level):void {
			if (selected != null) {
				SoundSystem.play("move");
			}
			x = level.x - 10;
			y = level.y - 10;
			selected = level;
		}
	}
}
