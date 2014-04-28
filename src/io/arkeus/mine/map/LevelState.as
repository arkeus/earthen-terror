package io.arkeus.mine.map {
	import io.arkeus.mine.assets.Resource;
	import io.arkeus.mine.game.GameState;
	import io.arkeus.mine.game.board.Block;
	import io.arkeus.mine.game.board.BlockType;
	import io.arkeus.mine.util.Difficulty;
	import io.arkeus.mine.util.Registry;
	import io.arkeus.mine.util.SoundSystem;
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
		private var shown:Boolean = false;
		
		public function LevelState(level:Level) {
			this.level = level;
		}
		
		override public function create():void {
			noScroll();
			
			add(frame = new AxSprite(0, 0));
			frame.create(150, 152, 0xcc000000);
			frame.x = (Ax.viewWidth - frame.width) / 2;
			frame.y = (Ax.viewHeight - frame.height) / 2;
			frame.centerOrigin();
			frame.scale.x = frame.scale.y = 0;
			frame.effects.grow(0.25, 1, 1, show);
			cy = frame.y + 8;
		}
		
		override public function update():void {
			if (!done && shown) {
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
			}
			
			super.update();
		}
		
		private function show():void {
			var text:AxText;
			add(text = new AxText(frame.x, cy, null, "@[ffff00]" + level.name, frame.width, "center"));
			cy += text.height + 6;
			line();
			var enemies:Array = [BlockType.SLIME, BlockType.LION, BlockType.MOUSE, BlockType.SQUID, BlockType.RABBIT];
			for (var i:uint = 0; i < enemies.length; i++) {
				var type:uint = enemies[i];
				var enemy:AxSprite = new AxSprite(3 + frame.x + i * 30, cy, Resource.BLOCKS, 20, 20);
				switch (type) {
					case BlockType.SLIME:  {
						enemy.animations.add("enemy", [12, 13, 12, 14], 8);
						break;
					}
					case BlockType.SQUID:  {
						enemy.animations.add("enemy", [15, 16, 15, 17], 8);
						break;
					}
					case BlockType.RABBIT:  {
						enemy.animations.add("enemy", [18, 19, 18, 20], 8);
						break;
					}
					case BlockType.LION:  {
						enemy.animations.add("enemy", [21, 22, 21, 23], 8);
						break;
					}
					case BlockType.MOUSE:  {
						enemy.animations.add("enemy", [24, 25, 24, 26], 8);
						break;
					}
				}
				enemy.animations.play("enemy");
				if (level.enemies.indexOf(type) == -1) {
					enemy.color.hex = 0x99000000;
				}
				add(enemy);
			}
			cy += 24;
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
			var endless:String = Registry.progress[level.index - 1] == 1 ? "Endless" : "Locked";
			add(mode = new Selectors(frame.x, cy, ["Goal", endless], frame.width));
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
			shown = true;
		}
		
		private function hide():void {
			shown = false;
			SoundSystem.play("cancel");
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
				SoundSystem.play("select");
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
