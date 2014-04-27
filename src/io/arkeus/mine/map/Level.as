package io.arkeus.mine.map {
	import io.arkeus.mine.assets.Resource;
	import io.arkeus.mine.util.Registry;
	import io.axel.sprite.AxSprite;

	public class Level extends AxSprite {
		public var index:uint;
		public var name:String;
		public var goal:uint;
		public var enemies:Array;
		
		public function Level(x:uint, y:uint, index:uint, name:String, goal:uint, enemies:Array) {
			super(x, y, Resource.MAP_LEVEL, 8, 8);
			this.index = index;
			this.name = name;
			this.goal = goal;
			this.enemies = enemies;
			var progress:uint = Registry.progress[index - 1];
			if (index == 1) {
				show(progress == 1 ? 0 : 1);
			} else {
				var previous:uint = Registry.progress[index - 2];
				show(progress == 1 ? 0 : (previous == 1 ? 1 : 2));
			}
		}
	}
}
