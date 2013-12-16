--[[
Author: Joel Van Eenwyk
Purpose: Manages what happens when the player hits an asteroid or other asteroid
--]]

-- info fields: HitPoint, HitNormal, Force, RelativeVelocity,
--              ColliderType, ColliderObject (maybe nil)
function OnCollision(self, info)
	if G.asteroids == nil then
		return
	end

	for _, asteroid in pairs(G.asteroids) do
		-- if asteroids collide, then we move them away from each other
		if self == asteroid.entity or info.ColliderObject == asteroid.rigidBody then
			if info.ColliderObject == G.player then
				Game:CreateEffect(
					G.player:GetPosition(),
					"Particles\\shipExplosion.xml",
					"shipExplosion" )
				Game:CreateEffect(
					asteroid.entity:GetPosition(),
					"Particles\\asteroidExplosion.xml",
					"astroidExplosion" )
				G.player:SetVisible(false)
				G.player:SetPosition( Vision.hkvVec3(10000, 10000, 10000) )
				G.Reset(2)
			end

			if asteroid.changeDirectionTimer > G.directionChangeTime then
				local offset = asteroid.entity:GetPosition() - info.ColliderObject:GetPosition()
				offset:normalize()

				asteroid.direction = offset
				asteroid.changeDirectionTimer = 0
			end
		end
	end		
end
