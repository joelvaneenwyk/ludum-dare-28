--[[
Author: Joel Van Eenwyk
Purpose: Controls the player
--]]

function OnExpose(self)
	self.MissileVelocity = 600
	self.MissileScale = 0.2
	self.MoveSpeed = 300
	self.RotateSpeed = 5
end

function OnAfterSceneLoaded(self)
	Debug:Enable(true)

	local kDeadzone = {deadzone = 0.1}
 
	G.screenWidth, G.screenHeight = Screen:GetViewportSize()

	self.playerInputMap = Input:CreateMap("InputMap")
 
	-- Setup the WASD keyboard playerInputMap
	self.playerInputMap:MapTrigger("KeyLeft", "KEYBOARD", "CT_KB_A")
	self.playerInputMap:MapTrigger("KeyRight", "KEYBOARD", "CT_KB_D")
	self.playerInputMap:MapTrigger("KeyUp", "KEYBOARD", "CT_KB_W")
	self.playerInputMap:MapTrigger("KeyDown", "KEYBOARD", "CT_KB_S")
	self.playerInputMap:MapTrigger("KeyFire", "KEYBOARD", "CT_KB_SPACE", {once=true})

	-- Create a virtual thumbstick then setup playerInputMap for it
	if Application:GetPlatformName() ~= "WIN32DX9" and
	   Application:GetPlatformName() ~= "WIN32DX11" then	
		Input:CreateVirtualThumbStick()
		self.playerInputMap:MapTriggerAxis("TouchLeft", "VirtualThumbStick", "CT_PAD_LEFT_THUMB_STICK_LEFT", kDeadzone)
		self.playerInputMap:MapTriggerAxis("TouchRight", "VirtualThumbStick", "CT_PAD_LEFT_THUMB_STICK_RIGHT", kDeadzone)
		self.playerInputMap:MapTriggerAxis("TouchUp", "VirtualThumbStick", "CT_PAD_LEFT_THUMB_STICK_UP", kDeadzone)
		self.playerInputMap:MapTriggerAxis("TouchDown", "VirtualThumbStick", "CT_PAD_LEFT_THUMB_STICK_DOWN", kDeadzone)
		self.playerInputMap:MapTrigger(
			"TouchFire",
			{ (G.screenWidth * 0.5), (G.screenHeight * 0.5), G.screenWidth, G.screenHeight },
			"CT_TOUCH_ANY")
	end

	self:SetUseEulerAngles(true)

	G.player = self
	
	local distance = 1600
	local p1 = Screen:Project3D(0, 0, distance)
	local p2 = Screen:Project3D(G.screenWidth, G.screenHeight, distance)
	G.extentX = math.abs((p2.x - p1.x) / 2)
	G.extentY = math.abs((p2.y - p1.y) / 2)
		
	G.Reset = Reset
	G.Reset(0.0)

end

function OnBeforeSceneUnloaded(self)
	Input:DestroyVirtualThumbStick()
	Input:DestroyMap(self.playerInputMap)
end

function IsTriggered(self, key)
	return (self.playerInputMap:GetTrigger(key) > 0)
end

function OnThink(self)
	local dt = Timer:GetTimeDiff()
	
	-- Handle resetting immediately as some things need to be initialized right away
	if G.reset then
		G.resetTime = G.resetTime - dt
		if G.resetTime <= 0 then
			HardReset()
			G.reset = false
		end
	end
	
	local moveSpeed = self.MoveSpeed * dt
	local rotateSpeed = self.RotateSpeed * dt
	
	local delta = Vision.hkvVec3(0, 0, 0)
	local rotate = 0

	Debug.Draw:Line(
		Vision.hkvVec3(-G.extentX, -G.extentY, 0),
		Vision.hkvVec3(G.extentX, -G.extentY, 0) )
	Debug.Draw:Line(
		Vision.hkvVec3(-G.extentX, G.extentY, 0),
		Vision.hkvVec3(G.extentX, G.extentY, 0) )
	Debug.Draw:Line(
		Vision.hkvVec3(-G.extentX, -G.extentY, 0),
		Vision.hkvVec3(-G.extentX, G.extentY, 0) )
	Debug.Draw:Line(
		Vision.hkvVec3(G.extentX, -G.extentY, 0),
		Vision.hkvVec3(G.extentX, G.extentY, 0) )

	if IsTriggered(self, "KeyUp") or IsTriggered(self, "TouchUp") then
		G.speed = G.speed + moveSpeed
	end

	if IsTriggered(self, "KeyLeft") or IsTriggered(self, "TouchLeft") then
		rotate = rotate - rotateSpeed
	end

	if IsTriggered(self, "KeyRight") or IsTriggered(self, "TouchRight") then
		rotate = rotate + rotateSpeed
	end
	
	local right = G.direction:cross(Vision.hkvVec3(0, 0, 1))
	
	G.direction = G.direction + right * rotate
	G.direction:normalize()
	
	local position = self:GetPosition() + G.direction * G.speed
	
	if position.x > G.extentX then
		position.x = G.extentX
	elseif position.x < -G.extentX then
		position.x = -G.extentX
	end
	
	if position.y > G.extentY then
		position.y = G.extentY
	elseif position.y < -G.extentY then
		position.y = -G.extentY
	end
	
	self:SetPosition(position)

	local angle = 0
	angle = math.atan2(G.direction.y, G.direction.x)
	self:SetOrientation(math.deg(angle) - 90, 0, 0)

	G.speed = G.speed * 0.9
		
	if (IsTriggered(self, "KeyFire") or IsTriggered(self, "TouchFire")) then
		G.missilePosition = position
		G.missileDirection = G.direction
		G.missileBounces = 0
		G.missileFired = true
		G.missilePath = {}
		table.insert(G.missilePath, G.missileDirection)
		G.missileEffect = Game:CreateEffect(
			G.missilePosition,
			"Particles\\shipThruster.xml",
			"astroidExplosion" )
	end
	
	if G.missileFired then		
		local rayStart = G.missilePosition
		local rayEnd = rayStart + G.missileDirection * 50
		local iCollisionFilterInfo = Physics.CalcFilterInfo(Physics.LAYER_ALL, 0, 0, 0)
		local isHit, result = Physics.PerformRaycast(rayStart, rayEnd, iCollisionFilterInfo)

		local e = rayStart + G.missileDirectio;
		Debug.Draw:Box(rayStart, 10)
		Debug.Draw:Line(rayStart, rayEnd, Vision.V_RGBA_WHITE)
		
		if isHit == true then 
			G.missilePosition = result.ImpactPoint
			G.missileDirection = result.ImpactNormal
			G.missileDirection.z = 0
			G.missileDirection:normalize()
			G.missileBounces = G.missileBounces + 1
		
			DeleteAsteroid(result.HitObject)

			Debug.Draw:Line(rayStart, result.ImpactPoint, Vision.V_RGBA_BLUE)
		else
			G.missilePosition = rayEnd
		end
		
		if G.missilePosition.x > G.extentX then
			G.missilePosition.x = G.extentX
			G.missileDirection.x = -G.missileDirection.x
			G.missileBounces = G.missileBounces + 1
		elseif G.missilePosition.x < -G.extentX then
			G.missilePosition.x = -G.extentX
			G.missileDirection.x = -G.missileDirection.x
			G.missileBounces = G.missileBounces + 1
		elseif G.missilePosition.y > G.extentY then
			G.missilePosition.y = G.extentY
			G.missileDirection.y = -G.missileDirection.y
			G.missileBounces = G.missileBounces + 1
		elseif G.missilePosition.y < -G.extentY then
			G.missilePosition.y = -G.extentY
			G.missileDirection.y = -G.missileDirection.y
			G.missileBounces = G.missileBounces + 1
		end
	end
	
	UpdateAsteroids(self)
end

--== Global game utility functions

function Reset(delay)
	G.missileFired = false

	G.reset = true
	G.resetTime = delay
end

function HardReset()
	DeleteAsteroids()

	G.missileFireTimer = 0
	
	G.direction = Vision.hkvVec3(0, 1, 0)
	G.speed = 0
	G.missilePosition = Vision.hkvVec3(0, 0, 0)
	G.missileDirection = Vision.hkvVec3(0, 0, 0)
	G.missileBounces = 0
	G.missilePath = {}
	G.missileFireTimer = 0.1

	G.currentLevel = 0
	G.asteroidCount = 3
	G.asteroidTime = 0

	G.directionChangeTime = 0.3

	G.player:SetPosition( Vision.hkvVec3(0, 0, 0) )
	G.player:SetVisible(true)
end

--== Asteroid helper functions

function UpdateAsteroids(self)
	local dt = Timer:GetTimeDiff()

	for i, asteroid in pairs(G.asteroids) do		
		local position = asteroid.entity:GetPosition()
		position = position + asteroid.direction * asteroid.speed * dt
		
		if position.x > G.extentX then
			position.x = G.extentX
			asteroid.direction.x = -asteroid.direction.x
		elseif position.x < -G.extentX then
			position.x = -G.extentX
			asteroid.direction.x = -asteroid.direction.x
		elseif position.y > G.extentY then
			position.y = G.extentY
			asteroid.direction.y = -asteroid.direction.y
		elseif position.y < -G.extentY then
			position.y = -G.extentY
			asteroid.direction.y = -asteroid.direction.y
		end
		
		asteroid.rotation = asteroid.rotation + asteroid.rotationSpeed * dt
		asteroid.rigidBody:SetOrientation( Vision.hkvVec3(0, 0, asteroid.rotation) )

		asteroid.rigidBody:SetPosition(position)
		
		asteroid.changeDirectionTimer = asteroid.changeDirectionTimer + dt
	end
	
	G.asteroidTime = G.asteroidTime + dt
	if G.asteroidTime > Util:GetRandFloat(2) + 0.5 and
	   table.getn(G.asteroids) < G.asteroidCount then
		CreateAsteroid(self)
		G.asteroidTime = 0
	end
end

function DeleteAsteroid(asteroidToDelete)
	if G.asteroids then
		for asteroidIndex, asteroid in pairs(G.asteroids) do
			if asteroid.entity == asteroidToDelete then
				Game:CreateEffect(
					asteroid.entity:GetPosition(),
					"Particles\\asteroidExplosion.xml",
					"asteroidExplosion" )

				asteroid.entity:Remove()
				table.remove(G.asteroids, asteroidIndex)
				break
			end
		end
	end
end

function DeleteAsteroids()
	if G.asteroids then
		for _, asteroid in pairs(G.asteroids) do
			asteroid.entity:Remove()
		end
	end

	G.asteroids = {}
end

function CreateAsteroid()
	local position = Vision.hkvVec3(0, 0, -5.0)
	local variation = 4 --Util:GetRandInt(3) + 1
	local model = "Models/asteroid0" .. variation .. ".model"
	local collision = "Models/asteroid_collision.hkt"

	local asteroid = {}
	
	asteroid.direction = Vision.hkvVec3(0, 0, 0)
	
	if Util:GetRandFloat() > 0.5 then
		if Util:GetRandFloat() > 0.5 then
			position.x = G.extentX * -1
			asteroid.direction.x = 1
		else
			position.x = G.extentX
			asteroid.direction.x = -1
		end
		asteroid.direction.y = Util:GetRandFloat(2) - 1
		position.y = Util:GetRandFloat(G.extentY)
	else
		if Util:GetRandFloat() > 0.5 then
			position.y = G.extentY * -1
			asteroid.direction.y = 1
		else
			position.y = G.extentY
			asteroid.direction.y = -1
		end	
		asteroid.direction.x = Util:GetRandFloat(2) - 1
		position.x = Util:GetRandFloat(G.extentX)
	end

	asteroid.direction:normalize()
	
	asteroid.scale = Util:GetRandFloat(2) + 1.5
	asteroid.entity = Game:CreateEntity(
		position,
		"VisBaseEntity_cl",
		model,
		"Asteroid" )
	asteroid.entity:SetScaling(asteroid.scale)
	asteroid.rotationSpeed = Util:GetRandFloat(200) - 100
	asteroid.rotation = 0

	asteroid.rigidBody = asteroid.entity:AddComponentOfType("vHavokRigidBody")
	asteroid.rigidBody:SetDebugRendering(true)

	local aabb = asteroid.entity:GetCollisionBoundingBox()	
	local radius = math.max(aabb:getSizeX(), aabb:getSizeY()) / 2.0
	local success = asteroid.rigidBody:InitFromFile(collision, radius / 100.0)

	if success then
		asteroid.entity:AddComponentOfType("VScriptComponent", "AsteroidControlScript")
		asteroid.entity.AsteroidControlScript:SetProperty("ScriptFile", "Scripts/Asteroid.lua")
		asteroid.entity.AsteroidControlScript:SetOwner(asteroid.entity)
		
		asteroid.speed = Util:GetRandFloat(100) + 100
		asteroid.changeDirectionTimer = 0

		table.insert(G.asteroids, asteroid)
	else
		asteroid.entity:Remove()
	end
end
