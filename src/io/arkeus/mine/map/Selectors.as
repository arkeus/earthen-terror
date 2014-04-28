package io.arkeus.mine.map {
	import io.arkeus.mine.util.SoundSystem;
	import io.axel.Ax;
	import io.axel.AxU;
	import io.axel.base.AxGroup;
	import io.axel.input.AxKey;
	import io.axel.sprite.AxSprite;
	import io.axel.text.AxText;

	public class Selectors extends AxGroup {
		public var focused:Boolean;
		public var value:String;
		
		private var cursor:AxSprite;
		private var options:Vector.<AxText>;
		private var selected:uint;
		private var selectCallback:Function;
		private var chooseCallback:Function;
		private var choosable:Boolean = false;
		
		public function Selectors(x:uint, y:uint, optionArray:Array, width:uint, initialValue:String = null) {
			super(x, y);
			
			var eachWidth:uint = width / optionArray.length;
			add(cursor = new AxSprite(5, -3));
			cursor.create(eachWidth - 10, 14, 0xffff0000);
			cursor.centerOrigin();
			
			options = new Vector.<AxText>;
			for (var i:uint = 0; i < optionArray.length; i++) {
				var text:AxText = new AxText(i * eachWidth, 0, null, optionArray[i], eachWidth, "center");
				if (text.text == "Locked") {
					text.color.hex = 0xff777777;
				}
				add(text);
				options.push(text);
			}
			
			focused = false;
			selected = 0;
			move(0);
			
			if (initialValue != null) {
				for (i = 0; i < options.length; i++) {
					if (options[i].text == initialValue) {
						move(i);
					}
				}
			}
		}
		
		public function onSelect(callback:Function):void {
			this.selectCallback = callback;
		}
		
		public function onChoose(callback:Function):void {
			this.chooseCallback = callback;
		}
		
		override public function update():void {
			cursor.alpha = focused ? 1 : 0.4;
			
			if (focused) {
				if (Ax.keys.pressed(AxKey.RIGHT)) {
					move(1);
				} else if (Ax.keys.pressed(AxKey.LEFT)) {
					move(-1);
				} else if (Ax.keys.pressed(AxKey.SPACE) || Ax.keys.pressed(AxKey.ENTER) || Ax.keys.pressed(AxKey.Z) || Ax.keys.pressed(AxKey.W)) {
					if (chooseCallback != null) {
						if (choosable) {
							SoundSystem.play("select");
							choosable = false;
						}
						chooseCallback(value);
					}
				}
			}
			
			super.update();
		}
		
		private function move(delta:int):void {
			var selectedCandidate:uint = AxU.clamp(selected + delta, 0, options.length -1 );
			if (options[selectedCandidate].text == "Locked") {
				return;
			}
			if (delta != 0) {
				SoundSystem.play("move");
			}
			selected = selectedCandidate;
			cursor.x = options[selected].x + 5;
			value = options[selected].text;
			if (selectCallback != null) {
				selectCallback(value);
			}
		}
		
		public function focus():void {
			SoundSystem.play("move");
			focused = true;
			cursor.effects.grow(0.25, 1.15, 1.15);
			choosable = true;
		}
		
		public function blur():void {
			focused = false;
			cursor.effects.grow(0.25, 1, 1);
			choosable = false;
		}
	}
}
