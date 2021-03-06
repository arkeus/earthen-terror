package io.arkeus.mine.game.board {
	import io.arkeus.mine.assets.Particle;
	import io.arkeus.mine.ui.UI;
	import io.arkeus.mine.util.Difficulty;
	import io.arkeus.mine.util.Registry;
	import io.arkeus.mine.util.SoundSystem;
	import io.axel.Ax;
	import io.axel.AxU;
	import io.axel.base.AxGroup;
	import io.axel.input.AxKey;

	public class Board extends AxGroup {
		public static const WIDTH:uint = 6;
		public static const HEIGHT:uint = 4;
		public static const BOTTOM:uint = 280;
		public static const TOP:uint = BOTTOM - 12 * Block.SIZE;
		
		public var map:BlockMap;
		public var cursor:Cursor;
		public var blocks:AxGroup;
		public var copy:Array;
		public var rowsSinceEnemy:uint = 5;
		public var casts:AxGroup;
		public var spells:AxGroup;
		public var ui:UI;
		public var highest:int;
		
		public function Board(blah:Array = null) {
			super(21, Board.BOTTOM - HEIGHT * Block.SIZE);
			noScroll();
			
			Registry.board = this;
			this.height = HEIGHT;
			
			populate4(blah);
			
			add(cursor = new Cursor(0, 0));
			add(ui = new UI, false, false);
			add(Particle.initialize());
			add(spells = new AxGroup);
			add(casts = new AxGroup);
		}
		
		override public function update():void {
			map = buildMap();
			if (!Registry.game.ended) {
				populateAbove();
				handleInput();
				handleFalls();
				handleClears();
				
				if (highest > Board.TOP + 20 && (Ax.keys.held(AxKey.SHIFT) || Ax.keys.held(AxKey.C))) {
					velocity.y = -60;
				} else {
					switch (Registry.game.difficulty) {
						case Difficulty.EASY: velocity.y = -1 - Math.min(12, Registry.game.level) / 12; break;
						case Difficulty.NORMAL: velocity.y = -1.5 - Math.min(12, Registry.game.level) / 9; break;
						case Difficulty.HARD: velocity.y = -2 - Math.min(12, Registry.game.level) / 6; break;
					}				
				}
			} else {
				velocity.y = 0;
			}
			
			super.update();
			
			if (!Registry.game.ended) {
				handleStops();
				handleRows();
			}
		}
		
		private function handleInput():void {
			if (Ax.keys.pressed(AxKey.RIGHT)) {
				cursor.move(1, 0);
			}
			if (Ax.keys.pressed(AxKey.LEFT)) {
				cursor.move(-1, 0);
			}
			if (Ax.keys.pressed(AxKey.DOWN)) {
				cursor.move(0, 1);
			}
			if (Ax.keys.pressed(AxKey.UP)) {
				cursor.move(0, -1);
			}
			
			if (Ax.keys.pressed(AxKey.SPACE) || Ax.keys.pressed(AxKey.W) || Ax.keys.pressed(AxKey.Z)) {
				var left:Block = map.get(cursor.tx, cursor.ty) || createPlaceholder(cursor.tx, cursor.ty);
				var right:Block = map.get(cursor.tx + 1, cursor.ty) || createPlaceholder(cursor.tx + 1, cursor.ty);
				if (left.swapable && right.swapable && (!left.placeholder || !right.placeholder)) {
					SoundSystem.play("swap");
					swap(left, right);
				}
			}
		}
		
		private function createPlaceholder(tx:uint, ty:uint):Block {
			return new Block(tx, ty, BlockType.PLACEHOLDER);
		}
		
		private function handleClears():void {
			for (var i:uint = 0; i < blocks.members.length; i++) {
				var block:Block = blocks.members[i];
				if (!block.matchable || block.cleared || block.type > 9) {
					continue;
				}
				
				var left:Block = map.get(block.tx - 1, block.ty);
				var right:Block = map.get(block.tx + 1, block.ty);
				var down:Block = map.get(block.tx, block.ty + 1);
				var up:Block = map.get(block.tx, block.ty - 1);
				
				if ((left != null && block.type == left.type && left.matchable && !left.cleared) && (right != null && block.type == right.type && right.matchable && !right.cleared)) {
					clear(block, left, right);
				}
				
				if ((up != null && block.type == up.type && up.matchable && !up.cleared) && (down != null && block.type == down.type && down.matchable && !down.cleared)) {
					clear(block, up, down);
				}
			}
		}
		
		private function clear(...blocks:Array):void {
			var primary:Block = blocks.length > 1 ? blocks[1] : blocks[0];
			var enemy:Block = findNearestEnemy(primary);
			var combo:Boolean = false;
			for (var index:uint in blocks) {
				var block:Block = blocks[index];
				if (block.type > 1 && !block.marked) {
					if (block.comboable > 0) {
						combo = true;
					}
					if (!spelling || Math.random() < 0.3) {
						casts.add(new Cast(block.x, block.y, block.type, enemy));
					}
					var prop:Block = block.above;
					while (prop != null) {
						prop.comboEnabled = true;
						prop = prop.above;
					}
				}
				block.clear();
			}
			if (combo) {
				for (var i:uint = 0; i < 2; i++) {
					casts.add(new Cast(primary.x, primary.y, primary.type, enemy));
				}
			}
			SoundSystem.play("clear");
		}
		
		private function findNearestEnemy(source:Block):Block {
			var distanceSquared:Number = Number.MAX_VALUE;
			var closest:Block = null;
			for (var i:uint = 0; i < blocks.members.length; i++) {
				var block:Block = blocks.members[i];
				if (block.enemy && !block.inactive) {
					var dx:int = block.x - source.x;
					var dy:int = block.y - source.y;
					var newDistance:Number = dx * dx + dy * dy;
					if (newDistance < distanceSquared) {
						distanceSquared = newDistance;
						closest = block;
					}
				}
			}
			return closest;
		}
		
		private function handleFalls():void {
			for (var i:uint = 0; i < blocks.members.length; i++) {
				var block:Block = blocks.members[i];
				if (block.velocity.y != 0 || block.falling || !block.fallable) {
					continue;
				}
				if (block.ty < height - 1 && map.get(block.tx, block.ty + 1) == null) {
					var propagation:Block = block;
					while (propagation != null && propagation.fallable && !propagation.marked) {
						propagation.fall();
						propagation = propagation.above;
					}
				}
			}
		}
		
		private function handleStops():void {
			for (var i:uint = 0; i < blocks.members.length; i++) {
				var block:Block = blocks.members[i];
				if (block.velocity.y == 0) {
					continue;
				}
				var below:Block = map.get(block.tx, block.ty + 1);
				if (block.ty >= height - 1 || (below != null && below.velocity.y == 0)) {
					var propagation:Block = block;
					while (propagation != null && !propagation.marked) {
						propagation.land(below);
						below = propagation;
						propagation = propagation.above;
					}
				}
			}
		}
		
		private function buildMap():BlockMap {
			var map:BlockMap = new BlockMap;
			highest = int.MAX_VALUE;
			for (var i:uint = 0; i < blocks.members.length; i++) {
				var block:Block = blocks.members[i];
				map.set(block.tx, block.ty, block);
				if (block.globalY < highest && block.loseable) {
					highest = block.globalY;
				}
			}
			return map;
		}
		
		private function populateAbove():void {
			for (var i:uint = 0; i < blocks.members.length; i++) {
				var block:Block = blocks.members[i];
				if (block.matchable) {
					block.above = map.get(block.tx, block.ty - 1);
				}
			}
		}
		
		private function populate4(blah:Array):void {
			if (blah == null) {
				copy = [];
				for (var x:uint = 0; x < WIDTH; x++) {
					for (var y:uint = 0; y < height; y++) {
						copy.push(BlockType.random());
					}
				}
			} else {
				copy = blah;
			}
			
			add(blocks = new AxGroup);
			var copy2:Array = copy.concat();
			for (x = 0; x < WIDTH; x++) {
				for (y = 0; y < height; y++) {
					blocks.add(new Block(x, y, copy2.pop()));
				}
			}
			
			map = buildMap();
			for (var i:uint = 0; i < blocks.members.length; i++) {
				var block:Block = blocks.members[i];
				var left:Block = map.get(block.tx - 1, block.ty);
				var right:Block = map.get(block.tx + 1, block.ty);
				var down:Block = map.get(block.tx, block.ty + 1);
				var up:Block = map.get(block.tx, block.ty - 1);
				
				if (((left != null && block.type == left.type) && (right != null && block.type == right.type)) || ((up != null && block.type == up.type) && (down != null && block.type == down.type))) {
					var types:Array = [1, 2, 3, 4, 5];
					if (left != null && types.indexOf(left.type) != -1) {
						types.splice(types.indexOf(left.type), 1);
					}
					if (right != null && types.indexOf(right.type) != -1) {
						types.splice(types.indexOf(right.type), 1);
					}
					if (up != null && types.indexOf(up.type) != -1) {
						types.splice(types.indexOf(up.type), 1);
					}
					if (down != null && types.indexOf(down.type) != -1) {
						types.splice(types.indexOf(down.type), 1);
					}
					block.setType(types[0]);
				}
			}
		}
		
		private function handleRows():void {
			if (y + height * Block.SIZE < BOTTOM) {
				addRow();
			}
		}
		
		private function addRow():void {
			var block:Block;
			for (var x:uint = 0; x < WIDTH; x++) {
				if (rowsSinceEnemy > 4 && Math.random() < 0.10) {
					rowsSinceEnemy = 0;
					var enemies:Array = Registry.game.digsite.enemies;
					blocks.add(block = new Block(x, height, enemies[AxU.rand(0, enemies.length - 1)]));
				} else {
					blocks.add(block = new Block(x, height));
					block.inactive = true;
					var above:Block = map.get(block.tx, block.ty - 1);
					if (above != null && block.type == above.type) {
						block.setType(BlockType.random());
					}
					var left:Block = map.get(block.tx - 1, block.ty);
					if (left != null && block.type == left.type) {
						block.setType(BlockType.random());
					}
				}
			}
			rowsSinceEnemy++;
			height++;
		}
		
		private static const SWAP_TIME:Number = 0.1;
		private function swap(left:Block, right:Block):void {
			if (left.placeholder) {
				var lt:Block = map.get(left.tx, left.ty - 1);
				if (lt != null && lt.velocity.y > 0) {
					return;
				}
				blocks.add(left);
			}
			
			if (right.placeholder) {
				var rt:Block = map.get(right.tx, right.ty - 1);
				if (rt != null && rt.velocity.y > 0) {
					return;
				}
				blocks.add(right);
			}
			
			
			left.velocity.x = Block.SIZE / SWAP_TIME;
			right.velocity.x = -Block.SIZE / SWAP_TIME;
			left.ptx = right.tx;
			left.pty = right.ty;
			right.ptx = left.tx;
			right.pty = left.ty;
			left.swapping = true;
			right.swapping = true;
			var lx:uint = left.x;
			var ly:uint = left.y;
			var rx:uint = right.x;
			var ry:uint = right.y;
			
			map.set(left.tx, left.ty, right);
			map.set(right.tx, right.ty, left);
			
			timers.add(SWAP_TIME, function():void {
				left.x = rx;
				left.y = ry;
				right.x = lx;
				right.y = ly;
				left.velocity.x = 0;
				right.velocity.x = 0;
				left.swapping = right.swapping = false;
				
				if (left.alpha < 0.1) {
					left.explode();
				}
				if (right.alpha < 0.1) {
					right.explode();
				}
			});
		}
		
		public function meteor(x:int, y:int):void {
			var ctx:int = x / Block.SIZE;
			var cty:int = y / Block.SIZE;
			for (var tx:int = ctx - 1; tx < ctx + 3; tx++) {
				for (var ty:int = cty - 1; ty < cty + 2; ty++) {
					var block:Block = map.get(tx, ty);
					if (block != null && block.matchable && block.meteor < 0) {
						spellClear(block, 120);
					}
				}
			}
		}
		
		private static const SPELL_TIMER:uint = 30;
		public function lightning(x:int, y:int):void {
			var ctx:int = x / Block.SIZE;
			var cty:int = y / Block.SIZE;
			var left:Block = map.get(ctx - 1, cty);
			var right:Block = map.get(ctx, cty);
			if (left != null && left.lightning < 0) {
				left.lightning = SPELL_TIMER;
				spellClear(left, 120);
			}
			if (right != null && right.lightning < 0) {
				right.lightning = SPELL_TIMER;
				spellClear(right, 120);
			}
			left = map.get(ctx - 1, cty - 1);
			right = map.get(ctx, cty - 1);
			if (left != null && left.lightning < 0) {
				left.lightning = SPELL_TIMER;
				spellClear(left, 120);
			}
			if (right != null && right.lightning < 0) {
				right.lightning = SPELL_TIMER;
				spellClear(right, 120);
			}
		}
		
		public function douse(x:int, y:int):void {
			var ctx:int = x / Block.SIZE;
			var cty:int = y / Block.SIZE;
			var block:Block = map.get(ctx, cty);
			if (block != null && !block.marked && block.douse < 0) {
				block.douse = SPELL_TIMER;
				spellClear(block, 180);
			}
		}
		
		public function boulder(x:int, y:int):Boolean {
			var ctx:int = x / Block.SIZE;
			var cty:int = y / Block.SIZE;
			if (y < 0) {
				cty--;
			}
			var block:Block = map.get(ctx, cty);
			if (block != null && !block.marked && block.avalanche < 0) {
				block.avalanche = SPELL_TIMER;
				spellClear(block, 300);
				return true;
			}
			return false;
		}
		
		private var spelling:Boolean = false;
		private function spellClear(block:Block, damage:int):void {
			if (block.enemy) {
				block.hp -= damage;
			} else if (block.matchable) {
				spelling = true;
				clear(block);
				spelling = false;
			}
		}
		
		public function lose():void {
			for (var i:uint = 0; i < blocks.members.length; i++) {
				var block:Block = blocks.members[i];
				block.effects.fadeOut(1, 0.2);
			}
			cursor.visible = false;
		}
	}
}
