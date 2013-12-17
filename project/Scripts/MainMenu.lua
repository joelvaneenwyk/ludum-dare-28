--[[
Author: Ryan Monday
Purpose: Creates and manages the main menu.
--]]

function OnAfterSceneLoaded(self)
	self.titleEntity = Game:GetEntity("Title")
	self.titleControlsEntity = Game:GetEntity("titleControls")
	self.titleEntity:SetVisible(false)
    self.titleControlsEntity:SetVisible(false)
	
	self.musicLevel = .75
    self.musicCrossFadeTime = 2
	
	self.menuBlowup =  Fmod:CreateSound(Vision.hkvVec3(0,0,0), "Sounds/menuBlowup.wav", false, "menuBlowup")
	self.menuBullet =  Fmod:CreateSound(Vision.hkvVec3(0,0,0), "Sounds/menuBulletCollide.wav", false, "menuBullet")
end

function OnBeforeSceneUnloaded(self)
	if self.gameMusic ~= nil then
		self.gameMusic:Remove()
	end

	if self.menuMusic ~= nil then
		self.menuMusic:Remove()
	end

	Fmod:ResetAll ()
end

function OnThink(self)
	local dt = Timer:GetTimeDiff() 

	if G.ResetMenu == true then
		self.titleEntity:SetVisible(true)
		self.titleControlsEntity:SetVisible(true)
		
		if self.gameMusic ~= nil then
			self.gameMusic:FadeFromTo(self.musicLevel,0, self.musicCrossFadeTime)
		end
		if self.menuMusic ~= nil then
			self.menuMusic:FadeFromTo(0,self.musicLevel, self.musicCrossFadeTime)
		else
			self.menuMusic = Fmod:CreateSound(Vision.hkvVec3(0,0,0), "Sounds/menuMusic.mp3", true, "gameMusic")
		    self.mG.enuMusic:SetVolume (0)
		    self.menuMusic:Play()
		    self.menuMusic:FadeFromTo(0,self.musicLevel, self.musicCrossFadeTime)
		end
		
		G.ResetMenu = false
	end

	if G.EndMainMenu then
		self.titleEntity:SetVisible(false)
        self.titleControlsEntity:SetVisible(false)

		local titleFx = Game:CreateEffect(
			Vision.hkvVec3(-283, -253, 25),
			"Particles/title.xml",
			"TitleFX")
		local titleControlFx = Game:CreateEffect(
			self.titleControlsEntity:GetPosition(),
			"Particles/titleControls.xml",
			"TitleControlsFX")
			
	   if self.gameMusic ~= nil then
			self.gameMusic:FadeFromTo(0,self.musicLevel, self.musicCrossFadeTime)
	   else
		    self.gameMusic = Fmod:CreateSound(Vision.hkvVec3(0,0,0), "Sounds/gameMusic.mp3", true, "gameMusic")
		    self.gameMusic:SetVolume (0)
		    self.gameMusic:Play()
			self.gameMusic:FadeFromTo(0,self.musicLevel, self.musicCrossFadeTime)
	   end	
			
	   if self.menuMusic ~= nil then
			self.menuMusic:FadeFromTo(self.musicLevel,0, self.musicCrossFadeTime)
		end
		
	   self.menuBlowup:Play()
	  
	   G.MainMenu = false
	   G.EndMainMenu = false
	end
end
