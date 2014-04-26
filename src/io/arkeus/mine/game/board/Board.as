package io.arkeus.mine.game.board {
	import io.axel.Ax;
	import io.axel.base.AxGroup;
	import io.axel.input.AxKey;

	public class Board extends AxGroup {
		public static const WIDTH:uint = 6;
		public static const HEIGHT:uint = 12;
		
		public var map:BlockMap;
		public var cursor:Cursor;
		public var blocks:AxGroup;
		
		public function Board(x:uint, y:uint) {
			super(x, y);
			
			populate();
			
			add(cursor = new Cursor(0, 0));
		}
		
		override public function update():void {
			map = buildMap();
			populateAbove();
			handleFalls();
			handleInput();
			handleClears();
			
			super.update();
			
			handleStops();
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
		}
		
		private function createPlaceholder(tx:uint, ty:uint):Block {
			return new Block(tx * Block.SIZE, ty * Block.SIZE, BlockType.PLACEHOLDER);
		}
		
		private function handleClears():void {
			for (var i:uint = 0; i < blocks.members.length; i++) {
				var block:Block = blocks.members[i];
				if (!block.matchable) {
					continue;
				}
				
				var left:Block = map.get(block.tx - 1, block.ty);
				var right:Block = map.get(block.tx + 1, block.ty);
				var down:Block = map.get(block.tx, block.ty + 1);
				var up:Block = map.get(block.tx, block.ty - 1);
				
				if ((left != null && block.type == left.type && left.matchable) && (right != null && block.type == right.type && right.matchable)) {
					block.clear();
					left.clear();
					right.clear();
				}
				
				if ((up != null && block.type == up.type && up.matchable) && (down != null && block.type == down.type && down.matchable)) {
					block.clear();
					up.clear();
					down.clear();
				}
			}
		}
		
		private function handleFalls():void {
			for (var i:uint = 0; i < blocks.members.length; i++) {
				var block:Block = blocks.members[i];
				if (block.ty < HEIGHT - 1 && map.get(block.tx, block.ty + 1) == null) {
					var propagation:Block = block;
					while (propagation != null) {
						propagation.velocity.y = Block.SPEED;
						propagation = propagation.above;
					}
//					for (var ty:int = block.ty; ty > -1; ty--) {
//						var propagation:Block = map.get(block.tx, ty);
//						if (propagation != null) {
//							//propagation.angle = 45;
//							propagation.velocity.y = Block.SPEED;
//						}
//					}
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
				if (block.ty >= HEIGHT - 1 || (below != null && below.velocity.y == 0)) {
					var propagation:Block = block;
					while (propagation != null) {
						propagation.velocity.y = 0;
						propagation.y = propagation.ty * Block.SIZE;
						propagation = propagation.above;
					}
//					
//					for (var ty:int = block.ty; ty > -1; ty--) {
//						var propagation:Block = map.get(block.tx, ty);
//						if (propagation != null) {
//							//propagation.angle = 45;
//							propagation.velocity.y = 0;
//							propagation.y = propagation.ty * Block.SIZE;
//						} else {
//							break;
//						}
//					}
				}
			}
		}
		
		private function buildMap():BlockMap {
			var map:BlockMap = new BlockMap;
			for (var i:uint = 0; i < blocks.members.length; i++) {
				var block:Block = blocks.members[i];
//				if (block.matchable) {
					map.set(block.tx, block.ty, block);
//				}
//				if (block.velocity.y > 0) {
//					map.set(tx, ty + 1, block);
//				}
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
		
		private function populate():void {
			add(blocks = new AxGroup);
			for (var x:uint = 0; x < WIDTH; x++) {
				for (var y:uint = 0; y < HEIGHT; y++) {
					blocks.add(new Block(x * Block.SIZE, y * Block.SIZE));
				}
			}
		}
		
		private function swap(left:Block, right:Block):void {
			var tx:uint = left.x;
			var ty:uint = left.y;
			left.x = right.x;
			left.y = right.y;
			right.x = tx;
			right.y = ty;
			if (!left.placeholder) {
				map.set(left.tx, left.ty, left);
			} else {
				map.set(left.tx, left.ty, null);
			}
			if (!right.placeholder) {
				map.set(right.tx, right.ty, right);
			} else {
				map.set(right.tx, right.ty, null);
			}
		}
	}
}
