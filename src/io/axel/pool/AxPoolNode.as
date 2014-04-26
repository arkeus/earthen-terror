package io.axel.pool {
	/**
	 * A single node in a pool list. Contains the object and a pointer to the next
	 * node in the list.
	 */
	public class AxPoolNode {
		/** The node's object. */
		public var object:*;
		/** The pointer to the next node. */
		public var next:AxPoolNode;
	}
}
