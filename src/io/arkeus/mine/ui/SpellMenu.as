package io.arkeus.mine.ui {
	import io.arkeus.mine.assets.Resource;
	import io.arkeus.mine.game.board.Block;
	import io.arkeus.mine.game.board.Board;
	import io.arkeus.mine.game.spells.Boulder;
	import io.arkeus.mine.game.spells.Douse;
	import io.arkeus.mine.game.spells.Lightning;
	import io.arkeus.mine.game.spells.Meteor;
	import io.arkeus.mine.util.Registry;
	import io.arkeus.mine.util.SoundSystem;
	import io.axel.Ax;
	import io.axel.AxU;
	import io.axel.base.AxGroup;
	import io.axel.input.AxKey;
	import io.axel.sprite.AxSprite;

	public class SpellMenu extends AxGroup {
		private static const SPEED:uint = 150;
		private static const TIME:Number = 0.15;

		private var fire:AxSprite;
		private var earth:AxSprite;
		private var water:AxSprite;
		private var air:AxSprite;

		public var opened:Boolean = false;
		public var inProgress:Boolean = false;

		public function SpellMenu() {
			add(fire = new AxSprite(0, 0, Resource.CASTS_MENU, 20, 20));
			fire.show(0);
			add(earth = new AxSprite(0, 0, Resource.CASTS_MENU, 20, 20));
			earth.show(1);
			add(water = new AxSprite(0, 0, Resource.CASTS_MENU, 20, 20));
			water.show(2);
			add(air = new AxSprite(0, 0, Resource.CASTS_MENU, 20, 20));
			air.show(3);

			fire.alpha = earth.alpha = water.alpha = air.alpha = 0;
			opened = false;
		}

		override public function update():void {
			if (opened) {
				if (Ax.keys.pressed(AxKey.UP) && Registry.ui.fire >= Registry.ui.fireCost) {
					Registry.board.spells.add(new Meteor(Registry.board.cursor.center.x, Registry.board.cursor.center.y + 10));
					toggle(0, 0);
					Registry.ui.fire = 0;
					Registry.ui.fireCost = cost;
				} else if (Ax.keys.pressed(AxKey.DOWN) && Registry.ui.air >= Registry.ui.airCost) {
					Registry.board.spells.add(new Lightning(Registry.board.cursor.center.x, Registry.board.cursor.center.y));
					toggle(0, 0);
					Registry.ui.air = 0;
					Registry.ui.airCost = cost;
				} else if (Ax.keys.pressed(AxKey.LEFT) && Registry.ui.earth >= Registry.ui.earthCost) {
					for (var i:uint = 0; i < Board.WIDTH; i++) {
						Registry.board.spells.add(new Boulder(i * Block.SIZE, -Registry.board.y - AxU.rand(300, 800)));
						Registry.board.spells.add(new Boulder(i * Block.SIZE, -Registry.board.y - AxU.rand(300, 800)));
					}
					SoundSystem.play("avalanche");
					toggle(0, 0);
					Registry.ui.earth = 0;
					Registry.ui.earthCost = cost;
				} else if (Ax.keys.pressed(AxKey.RIGHT) && Registry.ui.water >= Registry.ui.waterCost) {
					SoundSystem.play("douse");
					Registry.board.spells.add(new Douse(-50, Registry.board.cursor.y + 2));
					toggle(0, 0);
					Registry.ui.water = 0;
					Registry.ui.waterCost = cost;
				} else if (Ax.keys.pressed(AxKey.ANY)) {
					toggle(0, 0);
				}
			}

			super.update();
		}

		private function get cost():uint {
			return UI.MAX_MANA + Math.min(Registry.game.level, 12) / 2;
		}
		
		public function toggle(x:uint, y:uint):void {
			if (!opened && !inProgress) {
				inProgress = true;
				opened = true;
				Registry.board.cursor.visible = false;
				fire.x = earth.x = water.x = air.x = x;
				fire.y = earth.y = water.y = air.y = y;
				fire.velocity.y = -SPEED;
				earth.velocity.x = -SPEED;
				water.velocity.x = SPEED;
				air.velocity.y = SPEED;
				fire.effects.fadeIn(TIME);
				earth.effects.fadeIn(TIME);
				water.effects.fadeIn(TIME);
				air.effects.fadeIn(TIME);

				fire.color.hex = Registry.ui.fire < Registry.ui.fireCost ? 0xff333333 : 0xffffffff;
				earth.color.hex = Registry.ui.earth < Registry.ui.earthCost ? 0xff333333 : 0xffffffff;
				water.color.hex = Registry.ui.water < Registry.ui.waterCost ? 0xff333333 : 0xffffffff;
				air.color.hex = Registry.ui.air < Registry.ui.airCost ? 0xff333333 : 0xffffffff;

				timers.add(TIME, function():void {
					fire.velocity.y = earth.velocity.x = water.velocity.x = air.velocity.y = 0;
					inProgress = false;
				});
			} else {
				inProgress = true;
				Registry.board.cursor.visible = true;
				fire.velocity.y = SPEED;
				earth.velocity.x = SPEED;
				water.velocity.x = -SPEED;
				air.velocity.y = -SPEED;
				fire.effects.fadeOut(TIME);
				earth.effects.fadeOut(TIME);
				water.effects.fadeOut(TIME);
				air.effects.fadeOut(TIME);
				opened = false;
				timers.add(TIME, function():void {
					fire.velocity.y = earth.velocity.x = water.velocity.x = air.velocity.y = 0;
					inProgress = false;
				});
			}
		}
	}
}
