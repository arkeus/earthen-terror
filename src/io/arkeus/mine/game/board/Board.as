package io.arkeus.mine.game.board {
	import io.arkeus.mine.util.Registry;
	import io.axel.Ax;
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
		
		public function Board(blah:Array) {
			super(21, Board.BOTTOM - HEIGHT * Block.SIZE);
			noScroll();
			
			Registry.board = this;
			this.height = HEIGHT;
			
			populate4(blah);
			add(casts = new AxGroup);
			add(cursor = new Cursor(0, 0));
		}
		
		override public function update():void {
			map = buildMap();
			populateAbove();
			handleFalls();
			handleInput();
			handleClears();
			
			if (Ax.keys.held(AxKey.SHIFT)) {
				velocity.y = -60;
			} else {
				velocity.y = -1;
			}
			
			super.update();
			
			handleStops();
			handleRows();
		}
		
		private function handleInput():void {
			if (Ax.keys.pressed(AxKey.D) || Ax.keys.pressed(AxKey.RIGHT)) {
				cursor.move(1, 0);
			}
			if (Ax.keys.pressed(AxKey.A) || Ax.keys.pressed(AxKey.LEFT)) {
				cursor.move(-1, 0);
			}
			if (Ax.keys.pressed(AxKey.S) || Ax.keys.pressed(AxKey.DOWN)) {
				cursor.move(0, 1);
			}
			if (Ax.keys.pressed(AxKey.W) || Ax.keys.pressed(AxKey.UP)) {
				cursor.move(0, -1);
			}
			
			if (Ax.keys.pressed(AxKey.SPACE)) {
				var left:Block = map.get(cursor.tx, cursor.ty) || createPlaceholder(cursor.tx, cursor.ty);
				var right:Block = map.get(cursor.tx + 1, cursor.ty) || createPlaceholder(cursor.tx + 1, cursor.ty);
				if (left.matchable && right.matchable) {
					swap(left, right);
				}
			}
			
			if (Ax.keys.pressed(AxKey.X)) {
				addRow();
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
			var primary:Block = blocks[1];
			var enemy:Block = findNearestEnemy(primary);
			for (var index:uint in blocks) {
				var block:Block = blocks[index];
				if (enemy != null && block.type > 1 && !block.marked) {
					casts.add(new Cast(block.x, block.y, block.type, enemy));
				}
				block.clear();
			}
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
				if (block.velocity.y != 0 || block.falling || !block.matchable) {
					continue;
				}
				if (block.ty < height - 1 && map.get(block.tx, block.ty + 1) == null) {
					var propagation:Block = block;
					while (propagation != null && propagation.matchable && !propagation.marked) {
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
			for (var i:uint = 0; i < blocks.members.length; i++) {
				var block:Block = blocks.members[i];
				map.set(block.tx, block.ty, block);
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
					var types:Array = [0, 1, 2, 3, 4, 5];
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
				if (rowsSinceEnemy > 6 && Math.random() < 0.16) {
					rowsSinceEnemy = 0;
					blocks.add(block = new Block(x, height, BlockType.SLIME));
				} else {
					blocks.add(block = new Block(x, height));
					block.inactive = true;
				}
			}
			rowsSinceEnemy++;
			height++;
		}
		
		private static const SWAP_TIME:Number = 0.1;
		private function swap(left:Block, right:Block):void {
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
			
			if (left.placeholder) {
				blocks.add(left);
			}
			if (right.placeholder) {
				blocks.add(right);
			}
			
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
	}
}
