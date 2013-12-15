-- info fields: HitPoint, HitNormal, Force, RelativeVelocity,
--              ColliderType, ColliderObject (maybe nil)
function OnCollision(self, info)
	for i, asteroid in pairs(G.asteroids) do
		-- if asteroids collide, then we move them away from each other
		if self == asteroid.entity or info.ColliderObject == asteroid.rigidBody then
			if asteroid.changeDirectionTimer > G.directionChangeTime then
				asteroid.direction = asteroid.direction * -1
				asteroid.changeDirectionTimer = 0
			end				
		end
	end		
end
