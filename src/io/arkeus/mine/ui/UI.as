package io.arkeus.mine.ui {
	import io.arkeus.mine.assets.Resource;
	import io.arkeus.mine.util.Difficulty;
	import io.arkeus.mine.util.Registry;
	import io.axel.Ax;
	import io.axel.base.AxGroup;
	import io.axel.input.AxKey;
	import io.axel.render.AxBlendMode;
	import io.axel.sprite.AxSprite;
	import io.axel.text.AxText;

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
		
		public var fireCost:int = MAX_MANA;
		public var earthCost:int = MAX_MANA;
		public var waterCost:int = MAX_MANA;
		public var airCost:int = MAX_MANA;
		
		public var fireText:AxText;
		public var earthText:AxText;
		public var waterText:AxText;
		public var airText:AxText;

		public var time:AxText;
		public var score:AxText;
		public var difficulty:AxText;
		public var spellMenu:SpellMenu;

		public function UI() {
			super();
			noScroll();
			Registry.ui = this;

			add(border = new AxSprite(0, 0, Resource.BORDER));
			border.noScroll();
			border.blend = AxBlendMode.TRANSPARENT_TEXTURE;

			add(fireBar = new AxSprite(175, 191, Resource.BARS, 73, 12));
			add(earthBar = new AxSprite(175, 216, Resource.BARS, 73, 12));
			add(waterBar = new AxSprite(175, 241, Resource.BARS, 73, 12));
			add(airBar = new AxSprite(175, 266, Resource.BARS, 73, 12));
			
			add(fireText = new AxText(175, 193, null, "Meteor", 73, "center"));
			add(earthText = new AxText(175, 218, null, "Avalanche", 73, "center"));
			add(waterText = new AxText(175, 243, null, "Douse", 73, "center"));
			add(airText = new AxText(175, 268, null, "@[000000]Lightning", 73, "center"));
			fireText.visible = earthText.visible = waterText.visible = airText.visible = false;

			fireBar.show(0);
			earthBar.show(1);
			waterBar.show(2);
			airBar.show(3);

			fireBar.scale.x = earthBar.scale.x = waterBar.scale.x = airBar.scale.x = 0;
			
			add(score = new AxText(148, 51, null, "0", 112, "center"));
			add(time = new AxText(148, 97, null, "2:45", 112, "center"));
			add(difficulty = new AxText(148, 143, null, Difficulty.toString(Registry.game.difficulty), 112, "center"));
			
			add(spellMenu = new SpellMenu);
			
			time.alpha = score.alpha = 0.8;
		}

		override public function update():void {
			fireBar.scale.x = Math.min(fire / MAX_MANA, 1);
			earthBar.scale.x = Math.min(earth / MAX_MANA, 1);
			waterBar.scale.x = Math.min(water / MAX_MANA, 1);
			airBar.scale.x = Math.min(air / MAX_MANA, 1);
			time.text = generateTimeString(Registry.game.end - Registry.game.start);
			
			fireText.visible = fire >= fireCost;
			earthText.visible = earth >= earthCost;
			waterText.visible = water >= waterCost;
			airText.visible = air >= airCost;
			
			if (Ax.keys.pressed(AxKey.X)) {
				Ax.keys.releaseAll();
				spellMenu.toggle(Registry.board.cursor.globalX + 13, Registry.board.cursor.globalY + 2);
			}

			super.update();
		}
		
		private static function generateTimeString(duration:int):String {
			var minutes:int = duration / 60000;
			duration -= minutes * 60000;
			var seconds:int = duration / 1000;
			return minutes + ":" + (seconds < 10 ? "0" + seconds : seconds);
		}
	}
}
