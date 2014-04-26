package io.arkeus.mine.game.board {
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	import io.arkeus.mine.util.Registry;
	import io.axel.Ax;
	import io.axel.base.AxGroup;
	import io.axel.input.AxKey;
	import io.axel.sprite.AxSprite;

	public class Board extends AxGroup {
		public static const WIDTH:uint = 6;
		public static const HEIGHT:uint = 4;
		public static const BOTTOM:uint = 280;
		public static const TOP:uint = BOTTOM - 12 * Block.SIZE;
		
		public var map:BlockMap;
		public var cursor:Cursor;
		public var blocks:AxGroup;
		public var copy:Array;
		public var debugBitmap:BitmapData;
		public var debugSprite:AxSprite;
		
		public function Board(x:uint, y:uint, blah:Array) {
			super(x, Board.BOTTOM - HEIGHT * Block.SIZE);
			Registry.board = this;
			this.height = HEIGHT;
			
			populate4(blah);
			
			debugBitmap = new BitmapData(WIDTH * Block.SIZE, HEIGHT * Block.SIZE * 4, true, 0x00ffffff);
			add(debugSprite = new AxSprite);
			debugSprite.load(debugBitmap);
			
			add(cursor = new Cursor(0, 0));
			
			velocity.y = -2;
		}
		
		override public function update():void {
			map = buildMap();
			//buildDebugSprite();
			populateAbove();
			handleFalls();
			handleInput();
			handleClears();
			
			if (Ax.keys.held(AxKey.SHIFT)) {
				velocity.y = -60;
			} else {
				velocity.y = -4;
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
//			if (!Ax.keys.pressed(AxKey.X)) {
//				return;
//			}
			for (var i:uint = 0; i < blocks.members.length; i++) {
				var block:Block = blocks.members[i];
				if (block.velocity.y != 0 || block.falling || !block.matchable) {
					continue;
				}
				if (block.ty < height - 1 && map.get(block.tx, block.ty + 1) == null) {
					var propagation:Block = block;
					var first:Boolean = true;
					while (propagation != null) {
//						propagation.velocity.y = Block.SPEED;
						propagation.fall();
						if (!first) {
							//propagation.scale.x *= 0.8;
						}
						first = false;
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
				if (block.ty >= height - 1 || (below != null && below.velocity.y == 0)) {
					var propagation:Block = block;
					while (propagation != null) {
						propagation.land(below);
						//propagation.y = propagation.ty * Block.SIZE;
						//propagation.scale.x *= 0.8;
						below = propagation;
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
				map.set(block.tx, block.ty, block);
//				if (block.velocity.y > 0) {
//					map.set(block.tx, block.ty + 1, block);
//				}
			}
			return map;
		}
		
		private function buildDebugSprite():void {
			debugBitmap.fillRect(new Rectangle(0, 0, debugBitmap.width, debugBitmap.height * 4), 0x00ffffff);
			for (var key:String in map.map) {
				var value:Block = map.map[key];
				if (value != null) {
					debugBitmap.fillRect(new Rectangle(value.x + 4, value.y + 4, value.width - 8, value.height - 8), 0xff000000);
				}
			}
			debugSprite.load(debugBitmap);
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
				for (var y:uint = 0; y < height; y++) {
					blocks.add(new Block(x, y));
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
		}
		
		private function handleRows():void {
			trace(y, height, y + height * Block.SIZE);
			if (y + height * Block.SIZE < BOTTOM) {
				addRow();
			}
		}
		
		private function addRow():void {
			for (var x:uint = 0; x < WIDTH; x++) {
				blocks.add(new Block(x, height));
			}
			height++;
		}
		
		private function populate2(blah:Array):void {
			add(blocks = new AxGroup);
			blocks.add(new Block(0, 11, BlockType.FIRE));
			blocks.add(new Block(0, 10, BlockType.AIR));
			blocks.add(new Block(0, 9, BlockType.EARTH));
			blocks.add(new Block(0, 8, BlockType.AIR));
			blocks.add(new Block(0, 7, BlockType.EARTH));
			blocks.add(new Block(0, 6, BlockType.FIRE));
			blocks.add(new Block(0, 5, BlockType.EARTH));
			blocks.add(new Block(0, 4, BlockType.AIR));
			blocks.add(new Block(0, 3, BlockType.EARTH));
			blocks.add(new Block(0, 2, BlockType.AIR));
			blocks.add(new Block(0, 1, BlockType.FIRE));
			blocks.add(new Block(0, 0, BlockType.AIR));
			
			blocks.add(new Block(1, 11, BlockType.AIR));
			blocks.add(new Block(1, 10, BlockType.AIR));
			blocks.add(new Block(1, 9, BlockType.AIR));
			blocks.add(new Block(1, 8, BlockType.STONE));
			blocks.add(new Block(1, 7, BlockType.FIRE));
			blocks.add(new Block(1, 6, BlockType.EARTH));
			blocks.add(new Block(1, 5, BlockType.FIRE));
			blocks.add(new Block(1, 4, BlockType.EARTH));
			blocks.add(new Block(1, 3, BlockType.STONE));
			blocks.add(new Block(1, 2, BlockType.FIRE));
			blocks.add(new Block(1, 1, BlockType.EARTH));
			blocks.add(new Block(1, 0, BlockType.AIR));
			
			blocks.add(new Block(2, 11, BlockType.AIR));
			blocks.add(new Block(2, 10, BlockType.AIR));
			blocks.add(new Block(2, 9, BlockType.FIRE));
			blocks.add(new Block(2, 8, BlockType.AIR));
			blocks.add(new Block(2, 7, BlockType.STONE));
			blocks.add(new Block(2, 6, BlockType.FIRE));
			blocks.add(new Block(2, 5, BlockType.FIRE));
			blocks.add(new Block(2, 4, BlockType.STONE));
			blocks.add(new Block(2, 3, BlockType.EARTH));
			blocks.add(new Block(2, 2, BlockType.FIRE));
			blocks.add(new Block(2, 1, BlockType.STONE));
			blocks.add(new Block(2, 0, BlockType.AIR));
			
			blocks.add(new Block(3, 11, BlockType.AIR));
			blocks.add(new Block(3, 10, BlockType.AIR));
			blocks.add(new Block(3, 9, BlockType.AIR));
		}
		
		private static const SWAP_TIME:Number = 0.15;
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
//				if (!left.placeholder) {
//					map.set(left.tx, left.ty, left);
//				} else {
//					map.set(left.tx, left.ty, null);
//				}
//				if (!right.placeholder) {
//					map.set(right.tx, right.ty, right);
//				} else {
//					map.set(right.tx, right.ty, null);
//				}
				left.velocity.x = 0;
				right.velocity.x = 0;
				left.swapping = right.swapping = false;
			});
		}
	}
}
