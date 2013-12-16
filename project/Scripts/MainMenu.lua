
function OnAfterSceneLoaded(self)
  self.menuMap = Input:CreateMap("MenuMap")
  self.w, self.h = Screen:GetViewportSize()
  Debug:Enable(true)
  
	self.menuMap:MapTrigger("X", "MOUSE", "CT_MOUSE_ABS_X")
  self.menuMap:MapTrigger("Y", "MOUSE", "CT_MOUSE_ABS_Y")
  self.menuMap:MapTrigger("Activate", "MOUSE", "CT_MOUSE_LEFT_BUTTON")
  
  if Application:GetPlatformName() ~= "WIN32DX9" or
	Application:GetPlatformName() ~= "WIN32DX11" then	
    self.menuMap:MapTrigger("Activate", {0, 0, self.w, self.h}, "CT_TOUCH_ANY")
    self.menuMap:MapTrigger("X", {0, 0, self.w, self.h}, "CT_TOUCH_ABS_X")
    self.menuMap:MapTrigger("Y", {0, 0, self.w, self.h}, "CT_TOUCH_ABS_Y")
  end
  
  self:SetTraceAccuracy(Vision.TRACE_AABOX)
  self.bulletRigid = self:GetComponentOfType("vHavokRigidBody")
  self.bulletOrient = 0
  self.picked = false
  self.startPos = self:GetPosition()
  
  G.MainMenu = true
  G.ResetMenu = false

end


function OnThink(self)
  local x = self.menuMap:GetTrigger("X")
  local y = self.menuMap:GetTrigger("Y")
  local dt = Timer:GetTimeDiff() 
  
  if G.ResetMenu == true then
  	Game:GetEntity("Title"):SetVisible(true)
    Game:GetEntity("menuArrow"):SetVisible(true)
	self:SetPosition(self.startPos)
	self.bulletRigid:SetPosition(self.startPos)
    self:SetVisible(true)
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
    
  if Application:GetPlatformName() == "WIN32DX9" or 
  Application:GetPlatformName() == "WIN32DX11" then
    -- draw cursor
	if G.MainMenu == true then
		Debug.Draw:Line2D(x,y,x+10,y+5, Vision.V_RGBA_WHITE)
		Debug.Draw:Line2D(x,y,x+5,y+10, Vision.V_RGBA_WHITE)
		Debug.Draw:Line2D(x+10,y+5,x+5,y+10, Vision.V_RGBA_WHITE)
	end
  end
end

function OnBeforeSceneUnloaded(self)
  Input:DestroyMap(self.map);
end

function OnCollision(self, info)
	if info.ColliderObject == Game:GetEntity("mainShip") and
	G.MainMenu == true then
		Game:GetEntity("Title"):SetVisible(false)
		Game:GetEntity("menuArrow"):SetVisible(false)
		self:SetVisible(false)
		self:SetPosition(self.startPos)
		self.bulletRigid:SetPosition(self.startPos)
		local titleFx = Game:CreateEffect(Vision.hkvVec3(-283,-253,25), "Particles/title.xml", "TitleFX")
		G.MainMenu = false
	end
end


