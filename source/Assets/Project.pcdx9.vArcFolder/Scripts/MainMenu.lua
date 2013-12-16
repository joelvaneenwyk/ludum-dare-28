--[[
Author: Ryan Monday
Purpose: Creates and manages the main menu.
--]]

function OnAfterSceneLoaded(self)
	self.menuMap = Input:CreateMap("MenuMap")
	G.screenWidth, G.screenHeight = Screen:GetViewportSize()
	
	Debug:Enable(true)

	self.menuMap:MapTrigger("X", "MOUSE", "CT_MOUSE_ABS_X")
	self.menuMap:MapTrigger("Y", "MOUSE", "CT_MOUSE_ABS_Y")
	self.menuMap:MapTrigger("Activate", "MOUSE", "CT_MOUSE_LEFT_BUTTON")

	if Application:GetPlatformName() ~= "WIN32DX9" or
		Application:GetPlatformName() ~= "WIN32DX11" then	
		self.menuMap:MapTrigger("Activate", {0, 0, G.screenWidth, G.screenHeight}, "CT_TOUCH_ANY")
		self.menuMap:MapTrigger("X", {0, 0, G.screenWidth, G.screenHeight}, "CT_TOUCH_ABS_X")
		self.menuMap:MapTrigger("Y", {0, 0, G.screenWidth, G.screenHeight}, "CT_TOUCH_ABS_Y")
	end

	self:SetTraceAccuracy(Vision.TRACE_AABOX)
	self.bulletRigid = self:GetComponentOfType("vHavokRigidBody")
	self.bulletOrient = 0
	self.picked = false
	self.startPos = self:GetPosition()
	
	self.titleEntity = Game:GetEntity("Title")
	self.titleControlsEntity = Game:GetEntity("titleControls")
	self.menuArrowEntity = Game:GetEntity("menuArrow")
	
	self.musicLevel = .75
    self.musicCrossFadeTime = 1
	
	self.menuMusic = Fmod:CreateSound(Vision.hkvVec3(0,0,0), "Sounds/menuMusic.mp3", true, "gameMusic")
	self.menuMusic:SetVolume (.2)
    self.menuMusic:Play()
    self.menuMusic:FadeFromTo(.2,self.musicLevel, self.musicCrossFadeTime)
		

end

function OnBeforeSceneUnloaded(self)
	Input:DestroyMap(self.map);
	if self.gameMusic ~= nil then
		self.gameMusic:Remove()
	end
	if self.menuMusic ~= nil then
		self.menuMusic:Remove()
	end
end

function OnThink(self)
	local x = self.menuMap:GetTrigger("X")
	local y = self.menuMap:GetTrigger("Y")
	local dt = Timer:GetTimeDiff() 

	if G.ResetMenu == true then
		self.titleEntity:SetVisible(true)
		self.titleControlsEntity:SetVisible(true)
		self.menuArrowEntity:SetVisible(true)
		self:SetPosition(self.startPos)
		self.bulletRigid:SetPosition(self.startPos)
		self:SetVisible(true)
		if self.gameMusic ~= nil then
			self.gameMusic:FadeFromTo(self.musicLevel,0, self.musicCrossFadeTime)
		end
		self.menuMusic = Fmod:CreateSound(Vision.hkvVec3(0,0,0), "Sounds/menuMusic.mp3", true, "gameMusic")
	    self.menuMusic:SetVolume (.2)
        self.menuMusic:Play()
        self.menuMusic:FadeFromTo(.2,self.musicLevel, self.musicCrossFadeTime)
		
		G.ResetMenu = false
	end

	if G.MainMenu == true then
		self.bulletRigid:SetOrientation( Vision.hkvVec3(self.bulletOrient, 0, 0) )
		self.bulletOrient = self.bulletOrient + (100  * dt)
	end

	if self.menuMap:GetTrigger("Activate") > 0 and (not self.picked) and
	   G.MainMenu == true then  
		local pickedEntity = Screen:PickEntity(x, y, 6000, true)
		local pickedPoint = Screen:PickPoint(x, y)

		if pickedEntity == self and pickedPoint ~= nil then
			self.picked = true
			self.pickedDistance = pickedPoint:getLength()
		end
	elseif self.picked and self.menuMap:GetTrigger("Activate") <= 0 then
		self.picked = false
	end

	if self.picked then
		self.point = Screen:Project3D(x, y, 1000)
		--Debug:PrintLine("Click: " .. self.point)
		self:SetPosition( Vision.hkvVec3(self.point.x, self.point.y, 0) )
		self.picked = true
	end

	if (Application:GetPlatformName() == "WIN32DX9" or 
	   Application:GetPlatformName() == "WIN32DX11") and
	   G.MainMenu then
		Debug.Draw:Line2D(x,y,x+10,y+5, Vision.V_RGBA_WHITE)
		Debug.Draw:Line2D(x,y,x+5,y+10, Vision.V_RGBA_WHITE)
		Debug.Draw:Line2D(x+10,y+5,x+5,y+10, Vision.V_RGBA_WHITE)
	end
	
	if self.gameMusic ~= nil and self.gameMusic:GetVolume () == 0 then
          self.gameMusic:Remove()
          self.gameMusic=nil
    end
	if self.menuMusic ~= nil and self.menuMusic:GetVolume () == 0 then
          self.menuMusic:Remove()
          self.menuMusic=nil
    end

end

function OnCollision(self, info)
	if info.ColliderObject == Game:GetEntity("mainShip") and
	   G.MainMenu == true then
		self.titleEntity:SetVisible(false)
		self.menuArrowEntity:SetVisible(false)
        self.titleControlsEntity:SetVisible(false)

		self:SetVisible(false)
		self:SetPosition( Vision.hkvVec3(10000,10000,10000) )
		self.bulletRigid:SetPosition( Vision.hkvVec3(10000,10000,10000) )

		local titleFx = Game:CreateEffect(
			Vision.hkvVec3(-283, -253, 25),
			"Particles/title.xml",
			"TitleFX")
		local titleControlFx = Game:CreateEffect(
			self.titleControlsEntity:GetPosition(),
			"Particles/titleControls.xml",
			"TitleControlsFX")
			
	   self.gameMusic = Fmod:CreateSound(Vision.hkvVec3(0,0,0), "Sounds/gameMusic.mp3", true, "gameMusic")
	   self.gameMusic:SetVolume (.2)
       self.gameMusic:Play()
       self.gameMusic:FadeFromTo(.2,self.musicLevel, self.musicCrossFadeTime)
	   
	   if self.menuMusic ~= nil then
			self.menuMusic:FadeFromTo(self.musicLevel,0, self.musicCrossFadeTime)
		end

	   G.MainMenu = false
	end
end


