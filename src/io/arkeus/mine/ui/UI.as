package io.arkeus.mine.ui {
	import io.arkeus.mine.assets.Resource;
	import io.axel.base.AxGroup;
	import io.axel.render.AxBlendMode;
	import io.axel.sprite.AxSprite;

	public class UI extends AxGroup {
		public static const MAX_MANA:uint = 20;
		
		public var border:AxSprite;
		public var fireBar:AxSprite;
		public var earthBar:AxSprite;
		public var waterBar:AxSprite;
		public var airBar:AxSprite;
		
		public var fire:int = 0;
		public var earth:int = 0;
		public var water:int = 0;
		public var air:int = 0;

		public function UI() {
			super();
			noScroll();

			add(border = new AxSprite(0, 0, Resource.BORDER));
			border.noScroll();
			border.blend = AxBlendMode.TRANSPARENT_TEXTURE;
			
			add(fireBar = new AxSprite(175, 191, Resource.BARS, 73, 12));
			add(earthBar = new AxSprite(175, 216, Resource.BARS, 73, 12));
			add(waterBar = new AxSprite(175, 241, Resource.BARS, 73, 12));
			add(airBar = new AxSprite(175, 266, Resource.BARS, 73, 12));
			
			fireBar.show(0);
			earthBar.show(1);
			waterBar.show(2);
			airBar.show(3);
			
			fireBar.scale.x = earthBar.scale.x = waterBar.scale.x = airBar.scale.x = 0;
		}
		
		override public function update():void {
			fireBar.scale.x = Math.min(fire / MAX_MANA, 1);
			earthBar.scale.x = Math.min(earth / MAX_MANA, 1);
			waterBar.scale.x = Math.min(water / MAX_MANA, 1);
			airBar.scale.x = Math.min(air / MAX_MANA, 1);
			
			super.update();
		}
	}
}
