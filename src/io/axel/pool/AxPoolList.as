package io.axel.pool {
	/**
	 * A linked list allowing to for easy pooling of objects.
	 */
	public class AxPoolList {
		/** A pointer to the first node in the list. */
		public var head:AxPoolNode;
		/** The size of the list. */
		public var size:uint = 0;
		
		/**
		 * Creates a new pool list with a pre-allocated set of nodes equal to the
		 * initial capacity.
		 * 
		 * @param initialCapacity The initial numebr of nodes to allocate.
		 * @throws ArgumentError If a negative initial capacity is passed.
		 */
		public function AxPoolList(initialCapacity:int = 0) {
			if (initialCapacity < 0) {
				throw new ArgumentError("Must supply non-negative capacity.");
			}
			for (var i:uint = 0; i < initialCapacity; i++) {
				add(new AxPoolNode);
			}
		}
		
		/**
		 * Removes the first node in the list and returns it. If the list is empty,
		 * creates a new node and returns it, and leaves the list empty.
		 * 
		 * @return A pool node. 
		 */
		public function remove():AxPoolNode {
			if (head == null) {
				return new AxPoolNode;
			} else {
				var node:AxPoolNode = head;
				head = head.next;
				size--;
				return node;
			}
		}
		
		/**
		 * Adds a node back onto the front of the list.
		 * 
		 * @param node The node to add.
		 * @throws ArgumentError If the node to add is null.
		 */
		public function add(node:AxPoolNode):void {
			if (node == null) {
				throw new ArgumentError("Cannot add null node to list");
			}
			node.next = head;
			head = node;
			size++;
		}
	}
}
