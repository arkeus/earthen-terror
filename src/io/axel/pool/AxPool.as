package io.axel.pool {
	/**
	 * A class that allows you to pool and reuse objects. Creates linked lists of objects that allow you to
	 * add and remove from the pool in constant time. List node objects are kept pooled in a separate list to
	 * prevent needing to allocate more unless you grow the list. Call remove() to get an instance of the
	 * object you are pooling, and add() it back when you are done. Always remember to add back anything you
	 * remove if you want to reuse it, and never add the same thing twice.
	 */
	public class AxPool {
		/** List of allocated objects. */
		public var allocated:AxPoolList;
		/** List of empty node wrappers to reuse when adding an object. */
		public var idle:AxPoolList;
		/** The class of the object to pool. */
		public var objectClass:Class;
		/** A function to run on an object upon allocation. */
		public var initialization:Function;
		
		/**
		 * Creates a new pool.
		 * 
		 * @param objectClass The class of the data to pool.
		 * @param initialCapacity The initial capacity of the pool.
		 * @param initialization The initialization function to call when allocating an object.
		 * @throws ArgumentError If the object class is null or the initial capacity is negative.
		 */
		public function AxPool(objectClass:Class, initialCapacity:int = 0, initialization:Function = null) {
			if (objectClass == null) {
				throw new ArgumentError("Must pass a class to pool");
			} else if (initialCapacity < 0) {
				throw new ArgumentError("Must pass a non-negative initial capacity");
			}
			
			this.objectClass = objectClass;
			this.initialization = initialization;
			
			idle = new AxPoolList;
			allocated = new AxPoolList;
			for (var i:uint = 0; i < initialCapacity; i++) {
				add(new objectClass);
			}
		}
		
		/**
		 * Removes a single object from the pool. If the pool is empty, allocates a new one and calls the initialization
		 * function on it.
		 * 
		 * @return The single object. 
		 */
		public function remove():* {
			var node:AxPoolNode = allocated.remove();
			var object:* = node.object;
			if (object == null) {
				object = new objectClass;
				if (initialization != null) {
					initialization(object);
				}
			}
			node.object = null;
			idle.add(node);
			return object;
		}
		
		/**
		 * Adds an object back into the pool. You should only ever add something that you obtained by calling remove() unless
		 * you are trying to seed the pool yourself.
		 * 
		 * @param object The object to add.
		 * @throws ArgumentError If the object to add is null.
		 */
		public function add(object:*):void {
			if (object == null) {
				throw new ArgumentError("Cannot add a null object to a pool");
			}
			var node:AxPoolNode = idle.remove();
			node.object = object;
			allocated.add(node);
		}
		
		/**
		 * The number of objects sitting in the pool. If this is greater than 0, calling remove() will return an object
		 * from the pool. If this is 0, calling remove() will allocate a new object and return it.
		 */
		public function get size():uint {
			return allocated.size;
		}
	}
}
