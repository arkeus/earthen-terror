package io.arkeus.mine.map {
	import io.arkeus.mine.game.board.BlockType;
	import io.arkeus.mine.util.Registry;
	import io.axel.Ax;
	import io.axel.base.AxGroup;
	import io.axel.input.AxKey;
	import io.axel.text.AxText;

	public class LevelSet extends AxGroup {
		public var cursor:LevelCursor;
		private var selected:AxText;

		private var level1:Level;
		private var level2:Level;
		private var level3:Level;
		private var level4:Level;
		private var level5:Level;

		public function LevelSet(initial:uint) {
			add(level1 = new Level(103, 210, 1, "Digsite Alpha", 8, [BlockType.SLIME]));
			add(level2 = new Level(183, 210, 2, "Digsite Beta", 11, [BlockType.SLIME, BlockType.LION]));
			add(level3 = new Level(133, 160, 3, "Digsite Gamma", 14, [BlockType.SLIME, BlockType.LION, BlockType.MOUSE]));
			add(level4 = new Level(93, 120, 4, "Digsite Delta", 17, [BlockType.SLIME, BlockType.LION, BlockType.MOUSE, BlockType.SQUID]));
			add(level5 = new Level(143, 70, 5, "Digsite Epsilon", 20, [BlockType.SLIME, BlockType.LION, BlockType.MOUSE, BlockType.SQUID, BlockType.RABBIT]));

			add(selected = new AxText(0, 284, null, "Choose A Digsite", Ax.viewWidth, "center"));
			add(cursor = new LevelCursor);
			switch (initial) {
				case 0: select(level1); break;
				case 1: select(level1); break;
				case 2: select(level2); break;
				case 3: select(level3); break;
				case 4: select(level4); break;
				case 5: select(level5); break;
			}
		}

		override public function update():void {
			switch (cursor.selected.index) {
				case 1:  {
					if (Ax.keys.pressed(AxKey.RIGHT)) {
						select(level2);
					}
					break;
				}
				case 2:  {
					if (Ax.keys.pressed(AxKey.LEFT)) {
						select(level1);
					} else if (Ax.keys.pressed(AxKey.UP)) {
						select(level3);
					}
					break;
				}
				case 3:  {
					if (Ax.keys.pressed(AxKey.DOWN) || Ax.keys.pressed(AxKey.RIGHT)) {
						select(level2);
					} else if (Ax.keys.pressed(AxKey.UP) || Ax.keys.pressed(AxKey.LEFT)) {
						select(level4);
					}
					break;
				}
				case 4:  {
					if (Ax.keys.pressed(AxKey.DOWN)) {
						select(level3);
					} else if (Ax.keys.pressed(AxKey.UP) || Ax.keys.pressed(AxKey.RIGHT)) {
						select(level5);
					}
					break;
				}
				case 5:  {
					if (Ax.keys.pressed(AxKey.DOWN) || Ax.keys.pressed(AxKey.LEFT)) {
						select(level4);
					}
					break;
				}
			}

			super.update();
		}

		private function select(level:Level):void {
			cursor.select(level);
			selected.text = level.index == 1 || Registry.progress[level.index - 2] == 1 ? level.name : "@[ff0000]Locked@[]";
		}
	}
}
