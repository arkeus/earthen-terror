package io.arkeus.mine.map {
	import io.arkeus.mine.game.GameState;
	import io.arkeus.mine.util.Difficulty;
	import io.arkeus.mine.util.Registry;
	import io.axel.Ax;
	import io.axel.base.AxEntity;
	import io.axel.input.AxKey;
	import io.axel.sprite.AxSprite;
	import io.axel.state.AxState;
	import io.axel.text.AxText;

	public class LevelState extends AxState {
		private var level:Level;
		private var frame:AxSprite;
		private var name:AxText;
		private var flavor:AxText;
		private var goal:AxText;
		private var difficulty:Selectors;
		private var mode:Selectors;
		private var actions:Selectors;
		
		private var cy:uint;
		
		public function LevelState(level:Level) {
			this.level = level;
		}
		
		override public function create():void {
			noScroll();
			
			add(frame = new AxSprite(0, 0));
			frame.create(150, 122, 0xcc000000);
			frame.x = (Ax.viewWidth - frame.width) / 2;
			frame.y = (Ax.viewHeight - frame.height) / 2;
			frame.centerOrigin();
			frame.scale.x = frame.scale.y = 0;
			frame.effects.grow(0.25, 1, 1, show);
			cy = frame.y + 8;
		}
		
		override public function update():void {
			if (Ax.keys.pressed(AxKey.ESCAPE) || Ax.keys.pressed(AxKey.X)) {
				hide();
				return;
			}
			
			if (Ax.keys.pressed(AxKey.DOWN)) {
				if (difficulty.focused) {
					difficulty.blur();
					mode.focus();
				} else if (mode.focused) {
					mode.blur();
					actions.focus();
				}
			} else if (Ax.keys.pressed(AxKey.UP)) {
				if (actions.focused) {
					actions.blur();
					mode.focus();
				} else if (mode.focused) {
					mode.blur();
					difficulty.focus();
				}
			}
			
			super.update();
		}
		
		private function show():void {
			var text:AxText;
			add(text = new AxText(frame.x, cy, null, "@[ffff00]" + level.name, frame.width, "center"));
			cy += text.height + 6;
			line();
			add(text = new AxText(frame.x, cy, null, "@[00ff00]" + "Choose Difficulty:", frame.width, "center"));
			cy += text.height + 6;
			add(difficulty = new Selectors(frame.x, cy, ["Easy", "Normal", "Hard"], frame.width, Registry.difficulty == -1 ? null : Difficulty.toString(Registry.difficulty)));
			difficulty.onSelect(function(value:String):void {
				Registry.difficulty = Difficulty.fromString(value);
			});
			difficulty.onChoose(function(value:String):void {
				Ax.keys.releaseAll();
				difficulty.blur();
				mode.focus();
			});
			cy += text.height + 6;
			line();
			add(text = new AxText(frame.x, cy, null, "@[00ff00]" + "Choose Mode:", frame.width, "center"));
			cy += text.height + 6;
			add(mode = new Selectors(frame.x, cy, ["Goal", "Endless"], frame.width));
			mode.onChoose(function(value:String):void {
				Ax.keys.releaseAll();
				mode.blur();
				actions.focus();
			});
			cy += text.height + 6;
			line();
			add(actions = new Selectors(frame.x, cy, ["Start", "Cancel"], frame.width));
			actions.onChoose(choose);
			
			difficulty.focus();
		}
		
		private function hide():void {
			for (var i:uint = 0; i < members.length; i++) {
				var member:AxEntity = members[i];
				if (member != frame) {
					member.visible = false;
				}
			}
			frame.effects.grow(0.25, 0, 0, function():void {
				Ax.states.pop();
			});
		}
		
		private function line():void {
			var line:AxSprite = new AxSprite(frame.x + 4, cy);
			line.create(frame.width - 8, 1, 0xaaffffff);
			add(line);
			cy += 7;
		}
		
		private var done:Boolean = false;
		private function choose(action:String):void {
			if (done) {
				return;
			}
			if (action == "Cancel") {
				hide();
			} else {
				done = true;
				Ax.camera.fadeOut(1, 0xff000000, function():void {
					Ax.states.pop();
					Ax.states.change(new GameState(Difficulty.fromString(difficulty.value), mode.value == "Goal" ? GameState.GOAL : GameState.ENDLESS, level));
					Ax.camera.fadeIn(1);
				});
			}
		}
	}
}
