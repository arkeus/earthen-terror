package io.axel.base {
	import io.axel.resource.AxResource;
	import io.axel.text.AxFont;
	import io.axel.text.AxText;
	import io.axel.sprite.AxSprite;

	/**
	 * A simple button class. This provides you with a simple button that has frames for idle,
	 * hover, and pressed states. Includes a default button. Also supports adding text in the
	 * font of your choosing, using the Axel system font by default. You can pass a function
	 * that will get called upon clicking by using the <code>onClick</code> function.
	 */
	public class AxButton extends AxSprite {
		/**
		 * The callback function that will be called upon clicking the button.
		 *
		 * @default null
		 */
		public var clickCallback:Function;
		/**
		 * The callback function that will be called when beginning to hover.
		 *
		 * @default null
		 */
		public var hoverCallback:Function;
		/**
		 * The callback function that will be called when leaving the hover area.
		 *
		 * @default null
		 */
		public var unhoverCallback:Function;
		/**
		 * This flag determines whether or not the callback function will be called when you
		 * release your mouse. If this is false (the default), it will be called when your
		 * click the button, rather than when you release it.
		 *
		 * @default false
		 */
		public var onRelease:Boolean;
		/**
		 * The text object that appears on the object (none by default). By default the text
		 * will be centered.
		 *
		 * @default null
		 */
		public var label:AxText;
		/**
		 * The y value of the label. By default it will be centered vertically when you add text.
		 */
		public var labelY:int = 0;
		/**
		 * The offset of the label. This is used so that when you hold down the button, the text
		 * is offset to provide a "push" looking animation.
		 */
		public var labelOffset:uint = 0;
		/**
		 * Whether or not you are currently hovering.
		 */
		public var hovering:Boolean = false;

		/**
		 * Creates a new button at the position you supply. By default it will use the system button
		 * graphic. If you provide a graphic, you should also provide a frame width and height, and
		 * your graphic should include 3 frames in this order: idle, hover, pressed.
		 *
		 * @param x The x value of the button.
		 * @param y The y value of the button.
		 * @param graphic The graphic to use for the button background.
		 * @param frameWidth The width of each frame in the button graphic.
		 * @param frameHeight The height of each frame in the button graphic.
		 *
		 */
		public function AxButton(x:Number, y:Number, graphic:Class = null, frameWidth:uint = 150, frameHeight:uint = 30) {
			super(x, y, graphic ? graphic : AxResource.BUTTON, frameWidth, frameHeight);
			animations.add("idle", [0], 0);
			animations.add("hover", [1], 0);
			animations.add("down", [2], 0);
		}

		/**
		 * Sets the label text on the button.
		 *
		 * @param str The string that should appear.
		 * @param font The font to use (by default uses the system font).
		 * @param verticalOffset The vertical position to place the text label.
		 * @param horizontalOffset The horizontal position to place the text label.
		 *
		 * @return This button.
		 */
		public function text(str:String, font:AxFont = null, verticalOffset:uint = 10, horizontalOffset:uint = 0):AxButton {
			if (font == null) {
				font = AxResource.font;
			}

			labelY = verticalOffset;
			label = new AxText(horizontalOffset, labelY, font, str, animations.frameWidth, "center");
			if (font == null) {
				label.setColor(.113, .113, .113);
			}
			label.setParent(this);

			return this;
		}

		/**
		 * @inheritDoc
		 */
		override public function update():void {
			if (released()) {
				if (clickCallback != null && onRelease) {
					clickCallback();
				}
				labelOffset = 0;
			} else if (clicked()) {
				if (clickCallback != null && !onRelease) {
					clickCallback();
				}
				labelOffset = 1;
			}

			if (held()) {
				animate("down");
				labelOffset = 1;
			} else if (hover()) {
				if (!hovering) {
					hovering = true;
					if (hoverCallback != null) {
						hoverCallback();
					}
				}
				animate("hover");
				labelOffset = 0;
			} else {
				if (hovering) {
					hovering = false;
					if (unhoverCallback != null) {
						unhoverCallback();
					}
				}
				animate("idle");
				labelOffset = 0;
			}

			super.update();
			
			if (label != null) {
				label.y = labelY + labelOffset;
				label.update();
			}
		}

		/**
		 * @inheritDoc
		 */
		override public function draw():void {
			super.draw();

			if (label != null) {
				label.scroll.x = scroll.x;
				label.scroll.y = scroll.y;
				label.draw();
			}
		}

		/**
		 * Sets the callback function for when you click the button. If the callback is null, nothing
		 * happens when you click.
		 *
		 * @param callback The function call upon clicking.
		 * @param onRelease Whether the callback should fire when releasing the mouse button (as opposed to when pressing).
		 *
		 * @return This button.
		 */
		public function onClick(callback:Function, onRelease:Boolean = true):AxButton {
			this.clickCallback = callback;
			this.onRelease = onRelease;
			return this;
		}
		
		/**
		 * Sets the callback function for when you start hovering. If the callback is null, nothing
		 * happens when you start hovering.
		 *
		 * @param callback The function call upon starting to hover.
		 *
		 * @return This button.
		 */
		public function onHover(callback:Function):AxButton {
			this.hoverCallback = callback;
			return this;
		}
		
		/**
		 * Sets the callback function for when you stop hovering. If the callback is null, nothing
		 * happens when you stop hovering.
		 *
		 * @param callback The function call upon stopping hovering.
		 *
		 * @return This button.
		 */
		public function onUnhover(callback:Function):AxButton {
			this.unhoverCallback = callback;
			return this;
		}
	}
}
