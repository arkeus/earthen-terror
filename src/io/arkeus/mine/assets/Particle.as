package io.arkeus.mine.assets {
	import io.axel.base.AxGroup;
	import io.axel.particle.AxParticleEffect;
	import io.axel.particle.AxParticleSystem;
	import io.axel.render.AxBlendMode;

	public class Particle {
		private static var particles:AxGroup;

		public static function initialize():AxGroup {
			if (particles != null) {
				return particles;
			}

			var effect:AxParticleEffect;
			particles = new ParticleGroup;

			effect = new AxParticleEffect("meteor", Resource.PARTICLES_RED, 30);
			effect.amount = 240;
			effect.x.min = -6, effect.x.max = 6;
			effect.y.min = -6, effect.y.max = 6;
			effect.frameSize.x = effect.frameSize.y = 5;
			effect.blend = AxBlendMode.PARTICLE;
			effect.xVelocity.min = 5, effect.xVelocity.max = 50;
			effect.yVelocity.min = -5, effect.yVelocity.max = -50;
			effect.lifetime.min = 0.5, effect.lifetime.max = 1;
			particles.add(AxParticleSystem.register(effect));
			
			effect = new AxParticleEffect("lightning", Resource.PARTICLES_YELLOW, 30);
			effect.amount = 30;
			effect.x.min = -10, effect.x.max = 10;
			effect.y.min = -60, effect.y.max = 60;
			effect.frameSize.x = effect.frameSize.y = 5;
			effect.blend = AxBlendMode.PARTICLE;
			effect.xVelocity.min = -50, effect.xVelocity.max = 50;
			effect.yVelocity.min = -5, effect.yVelocity.max = -20;
			effect.lifetime.min = 0.5, effect.lifetime.max = 1;
			particles.add(AxParticleSystem.register(effect));
			
			effect = new AxParticleEffect("douse", Resource.PARTICLES_BLUE, 30);
			effect.amount = 120;
			effect.x.min = -5, effect.x.max = 5;
			effect.y.min = -5, effect.y.max = 5;
			effect.frameSize.x = effect.frameSize.y = 5;
			effect.blend = AxBlendMode.PARTICLE;
			effect.xVelocity.min = -30, effect.xVelocity.max = -10;
			effect.yVelocity.min = -15, effect.yVelocity.max = 15;
			effect.lifetime.min = 0.5, effect.lifetime.max = 1;
			particles.add(AxParticleSystem.register(effect));
			
			effect = new AxParticleEffect("avalanche", Resource.PARTICLES_GREEN, 12);
			effect.amount = 50;
			effect.x.min = -5, effect.x.max = 5;
			effect.y.min = -5, effect.y.max = 5;
			effect.frameSize.x = effect.frameSize.y = 5;
			effect.blend = AxBlendMode.PARTICLE;
			effect.xVelocity.min = -60, effect.xVelocity.max = 60;
			effect.yVelocity.min = -180, effect.yVelocity.max = -120;
			effect.yAcceleration.min = 400, effect.yAcceleration.max = 600;
			effect.lifetime.min = 1, effect.lifetime.max = 2;
			particles.add(AxParticleSystem.register(effect));
			
			effect = new AxParticleEffect("unlock", Resource.PARTICLES_METAL, 30);
			effect.amount = 50;
			effect.x.min = 0, effect.x.max = 20;
			effect.y.min = 0, effect.y.max = 20;
			effect.frameSize.x = effect.frameSize.y = 4;
			effect.blend = AxBlendMode.BLEND;
			effect.xVelocity.min = -70, effect.xVelocity.max = 70;
			effect.yVelocity.min = -30, effect.yVelocity.max = -115;
			effect.lifetime.min = 0.5, effect.lifetime.max = 1;
			effect.yAcceleration.min = 200, effect.yAcceleration.max = 400;
			particles.add(AxParticleSystem.register(effect));
			
			var simples:Array = [
				["red", Resource.PARTICLES_RED_F],
				["green", Resource.PARTICLES_GREEN_F],
				["blue", Resource.PARTICLES_BLUE_F],
				["yellow", Resource.PARTICLES_YELLOW_F],
			];
			for each (var simple:Array in simples) {
				effect = new AxParticleEffect(simple[0], simple[1], 10);
				effect.amount = 100;
				effect.x.min = 7, effect.x.max = 11;
				effect.y.min = 7, effect.y.max = 11;
				effect.frameSize.x = effect.frameSize.y = 5;
				effect.blend = AxBlendMode.PARTICLE;
				effect.xVelocity.min = -30, effect.xVelocity.max = 30;
				effect.yVelocity.min = -30, effect.yVelocity.max = 30;
				effect.lifetime.min = 0.3, effect.lifetime.max = 0.7;
				particles.add(AxParticleSystem.register(effect));
			}
			
			effect = new AxParticleEffect("die", Resource.PARTICLES_RED_F, 4);
			effect.amount = 240;
			effect.x.min = 7, effect.x.max = 11;
			effect.y.min = 7, effect.y.max = 11;
			effect.frameSize.x = effect.frameSize.y = 5;
			effect.blend = AxBlendMode.PARTICLE;
			effect.xVelocity.min = -60, effect.xVelocity.max = 60;
			effect.yVelocity.min = -60, effect.yVelocity.max = 60;
			effect.lifetime.min = 0.6, effect.lifetime.max = 1;
			particles.add(AxParticleSystem.register(effect));
			
			effect = new AxParticleEffect("glass", Resource.PARTICLES_GLASS, 4);
			effect.amount = 120;
			effect.x.min = 7, effect.x.max = 11;
			effect.y.min = 7, effect.y.max = 11;
			effect.frameSize.x = effect.frameSize.y = 5;
			effect.blend = AxBlendMode.TRANSPARENT_TEXTURE;
			effect.xVelocity.min = -60, effect.xVelocity.max = 60;
			effect.yVelocity.min = -180, effect.yVelocity.max = -120;
			effect.yAcceleration.min = 400, effect.yAcceleration.max = 600;
			effect.lifetime.min = 1, effect.lifetime.max = 2;
			effect.startAlpha.min = 1, effect.startAlpha.max = 1;
			effect.endAlpha.min = 1, effect.endAlpha.max = 1;
			particles.add(AxParticleSystem.register(effect));

			return particles;
		}
	}
}
