package io.arkeus.mine.assets {
	import io.axel.base.AxGroup;
	import io.axel.particle.AxParticleCloud;

	public class ParticleGroup extends AxGroup {
		public function ParticleGroup(x:uint = 0, y:uint = 0) {
			super(x, y);
		}

		override public function dispose():void {
			for (var i:uint = 0; i < members.length; i++) {
				resetParticleCloud(members[i]);
			}
		}

		private function resetParticleCloud(group:AxGroup):void {
			for (var i:uint = 0; i < group.members.length; i++) {
				var cloud:AxParticleCloud = group.members[i] as AxParticleCloud;
				cloud.visible = cloud.exists = cloud.active = false;
				cloud.time = 0;
			}
		}
	}
}
