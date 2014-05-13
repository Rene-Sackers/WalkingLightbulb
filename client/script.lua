function math.round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

class("WalkingLightbulb")

function WalkingLightbulb:__init()
	self.mouseEvents = {
		[Action.LookDown] = true,
		[Action.LookLeft] = true,
		[Action.LookRight] = true,
		[Action.LookUp] = true,
		[Action.Fire] = true,
		[Action.FireLeft] = true,
		[Action.FireRight] = true,
		[Action.McFire] = true,
		[Action.VehicleFireLeft] = true,
		[Action.VehicleFireRight] = true
	}

	self.light = nil
	self.object = nil
	self.offset = Vector3(0, 2, 0)
	
	self:CreateGui()

	Events:Subscribe("KeyUp", self, self.KeyUp)
	Events:Subscribe("PreTick", self, self.PreTick)
	Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput)
	Events:Subscribe("ModuleUnload", function()
		if self.light ~= nil then self.light:Remove() end
		if self.object ~= nil then self.object:Remove() end
	end)
end

function WalkingLightbulb:UpdateColor()
	if self.light == nil then return end
	self.light:SetColor(self:GetColor())
end

function WalkingLightbulb:GetColor()
	return Color(self.redSlider:GetValue(), self.greenSlider:GetValue(), self.blueSlider:GetValue())
end

function WalkingLightbulb:CreateGui()
	self.window = Window.Create()
	self.window:SetVisible(false)
	self.window:SetSize(Vector2(300, 235))
	self.window:SetPadding(Vector2(5, 0), Vector2(5, 5))
	self.window:SetPositionRel(Vector2(0.5, 0.5) - self.window:GetSizeRel() / 2)
	self.window:DisableResizing()
	self.window:SetTitle("Walking Lightbulb")
	self.window:Subscribe("WindowClosed", function() Mouse:SetVisible(false) end)
	
	local enableCheckBox = LabeledCheckBox.Create(self.window)
	enableCheckBox:SetDock(GwenPosition.Top)
	enableCheckBox:GetLabel():SetText("Enable")
	enableCheckBox:GetCheckBox():Subscribe("CheckChanged", function()
		if self.light ~= nil then self.light:Remove() self.light = nil end
		
		if enableCheckBox:GetCheckBox():GetChecked() then
			local lightPosition = LocalPlayer:GetPosition() + Vector3(0, 10, 0)
			
			self.light = ClientLight.Create({
				-- -- Required:
				position = lightPosition,
				angle = Angle(0, 180, 0),
				color = self:GetColor(),
				-- -- Optional:
				constant_attenuation = 10,
				linear_attenuation = 1,
				quadratic_attenuation = 0.1,
				multiplier = 10.0,
				radius = 20.0,
				fade_in_duration = 0.2,
				fade_out_duration = 0.2
			})
			self.object = ClientStaticObject.Create({
				model = "cutscenetv2.eez/cutscene_prop_tv-a.lod",
				collision = "cutscenetv2.eez/cutscene_prop_tv_lod1-a_col.pfx",
				position = lightPosition,
				angle = Angle(LocalPlayer:GetAngle().yaw, 1.57, 0),
				world = LocalPlayer:GetWorld(),
				enabled = true,
				fixed = true
			})
		else
			if self.object ~= nil then self.object:Remove() self.object = nil end
		end
	end)
	
	local elevationLabel = Label.Create(self.window)
	elevationLabel:SetDock(GwenPosition.Top)
	elevationLabel:SetText("Elevation - " .. self.offset.y)
	
	local elevationSlider = HorizontalSlider.Create(self.window)
	elevationSlider:SetDock(GwenPosition.Top)
	elevationSlider:SetHeight(20)
	elevationSlider:SetMinimum(0)
	elevationSlider:SetMaximum(20)
	elevationSlider:SetValue(self.offset.y)
	elevationSlider:Subscribe("ValueChanged", function() elevationLabel:SetText("Elevation - " .. math.round(elevationSlider:GetValue(), 0)) self.offset = Vector3(0, elevationSlider:GetValue(), 0) end)
	
	local colorsBaseWindow = BaseWindow.Create(self.window)
	colorsBaseWindow:SetDock(GwenPosition.Top)
	colorsBaseWindow:SetHeight(30)
	colorsBaseWindow:SetWidthRel(1)
	colorsBaseWindow:SetMargin(Vector2(0, 5), Vector2(0, 0))
	
	local redBaseWindow = BaseWindow.Create(colorsBaseWindow)
	redBaseWindow:SetDock(GwenPosition.Left)
	redBaseWindow:SetSizeRel(Vector2(0.33, 1))
	local greenBaseWindow = BaseWindow.Create(colorsBaseWindow)
	greenBaseWindow:SetDock(GwenPosition.Left)
	greenBaseWindow:SetSizeRel(Vector2(0.33, 1))
	local blueBaseWindow = BaseWindow.Create(colorsBaseWindow)
	blueBaseWindow:SetDock(GwenPosition.Left)
	blueBaseWindow:SetSizeRel(Vector2(0.33, 1))
	
	local rLabel = Label.Create(redBaseWindow)
	rLabel:SetDock(GwenPosition.Top)
	rLabel:SetText("R - 255")
	self.redSlider = HorizontalSlider.Create(redBaseWindow)
	self.redSlider:SetDock(GwenPosition.Top)
	self.redSlider:SetHeight(20)
	self.redSlider:SetMinimum(0)
	self.redSlider:SetMaximum(255)
	self.redSlider:SetValue(255)
	self.redSlider:Subscribe("ValueChanged", function() rLabel:SetText("R - " .. math.round(self.redSlider:GetValue(), 0)) self:UpdateColor() end)
	
	local gLabel = Label.Create(greenBaseWindow)
	gLabel:SetDock(GwenPosition.Top)
	gLabel:SetText("G - 255")
	self.greenSlider = HorizontalSlider.Create(greenBaseWindow)
	self.greenSlider:SetDock(GwenPosition.Top)
	self.greenSlider:SetHeight(20)
	self.greenSlider:SetMinimum(0)
	self.greenSlider:SetMaximum(255)
	self.greenSlider:SetValue(255)
	self.greenSlider:Subscribe("ValueChanged", function() gLabel:SetText("G - " .. math.round(self.greenSlider:GetValue(), 0)) self:UpdateColor() end)
	
	local bLabel = Label.Create(blueBaseWindow)
	bLabel:SetDock(GwenPosition.Top)
	bLabel:SetText("B - 255")
	self.blueSlider = HorizontalSlider.Create(blueBaseWindow)
	self.blueSlider:SetDock(GwenPosition.Top)
	self.blueSlider:SetHeight(20)
	self.blueSlider:SetMinimum(0)
	self.blueSlider:SetMaximum(255)
	self.blueSlider:SetValue(255)
	self.blueSlider:Subscribe("ValueChanged", function() bLabel:SetText("B - " .. math.round(self.blueSlider:GetValue(), 0)) self:UpdateColor() end)
	
	local constantAttentuationLabel = Label.Create(self.window)
	constantAttentuationLabel:SetDock(GwenPosition.Top)
	constantAttentuationLabel:SetText("Constant attentuation - " .. 10)
	
	self.constantAttentuationSlider = HorizontalSlider.Create(self.window)
	self.constantAttentuationSlider:SetDock(GwenPosition.Top)
	self.constantAttentuationSlider:SetHeight(20)
	self.constantAttentuationSlider:SetMinimum(0)
	self.constantAttentuationSlider:SetMaximum(20)
	self.constantAttentuationSlider:SetValue(10)
	self.constantAttentuationSlider:Subscribe("ValueChanged", function()
		local value = self.constantAttentuationSlider:GetValue()
		constantAttentuationLabel:SetText("Contant attentuation - " .. math.round(value, 0))
		if self.light ~= nil then self.light:SetConstantAttenuation(value) end
	end)
	
	local linearAttentuationLabel = Label.Create(self.window)
	linearAttentuationLabel:SetDock(GwenPosition.Top)
	linearAttentuationLabel:SetText("Linear attentuation - " .. 10)
	
	self.linearAttentuationSlider = HorizontalSlider.Create(self.window)
	self.linearAttentuationSlider:SetDock(GwenPosition.Top)
	self.linearAttentuationSlider:SetHeight(20)
	self.linearAttentuationSlider:SetMinimum(0)
	self.linearAttentuationSlider:SetMaximum(20)
	self.linearAttentuationSlider:SetValue(10)
	self.linearAttentuationSlider:Subscribe("ValueChanged", function()
		local value = self.linearAttentuationSlider:GetValue()
		linearAttentuationLabel:SetText("Linear attentuation - " .. math.round(value, 0))
		if self.light ~= nil then self.light:SetLinearAttenuation(value) end
	end)
	
	local multiplierLabel = Label.Create(self.window)
	multiplierLabel:SetDock(GwenPosition.Top)
	multiplierLabel:SetText("Multiplier - " .. 10)
	
	self.multiplierAttentuationSlider = HorizontalSlider.Create(self.window)
	self.multiplierAttentuationSlider:SetDock(GwenPosition.Top)
	self.multiplierAttentuationSlider:SetHeight(20)
	self.multiplierAttentuationSlider:SetMinimum(0)
	self.multiplierAttentuationSlider:SetMaximum(20)
	self.multiplierAttentuationSlider:SetValue(10)
	self.multiplierAttentuationSlider:Subscribe("ValueChanged", function()
		local value = self.multiplierAttentuationSlider:GetValue()
		multiplierLabel:SetText("Multiplier - " .. math.round(value, 0))
		if self.light ~= nil then self.light:SetMultiplier(value) end
	end)
	
	local radiusLabel = Label.Create(self.window)
	radiusLabel:SetDock(GwenPosition.Top)
	radiusLabel:SetText("Radius - " .. 10)
	
	self.radiusAttentuationSlider = HorizontalSlider.Create(self.window)
	self.radiusAttentuationSlider:SetDock(GwenPosition.Top)
	self.radiusAttentuationSlider:SetHeight(20)
	self.radiusAttentuationSlider:SetMinimum(0)
	self.radiusAttentuationSlider:SetMaximum(20)
	self.radiusAttentuationSlider:SetValue(10)
	self.radiusAttentuationSlider:Subscribe("ValueChanged", function()
		local value = self.radiusAttentuationSlider:GetValue()
		radiusLabel:SetText("Radius - " .. math.round(value, 0))
		if self.light ~= nil then self.light:SetRadius(value) end
	end)
end

function WalkingLightbulb:KeyUp(args)
	if args.key ~= string.byte('L') then return end
	
	if self.window:GetVisible() then
		self.window:SetVisible(false)
		Mouse:SetVisible(false)
	else
		self.window:SetVisible(true)
	end
end

function WalkingLightbulb:PreTick()
	if self.window:GetVisible() and not Mouse:GetVisible() then Mouse:SetVisible(true) end
	if self.light ~= nil then self.light:SetPosition(LocalPlayer:GetPosition() + self.offset) end
	if self.object ~= nil then self.object:SetPosition(LocalPlayer:GetPosition() + self.offset) self.object:SetAngle(Angle(LocalPlayer:GetAngle().yaw, 1.57, 0)) end
end

function WalkingLightbulb:LocalPlayerInput(args)
	if self.window:GetVisible() and self.mouseEvents[args.input] then return false end
end

WalkingLightbulb()