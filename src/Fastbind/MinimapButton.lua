-- Fastbind
-- The MIT License © 2017 Arthur Corenzan
-- More on https://github.com/haggen/wow

-- Add-on name constant.
--
local FASTBIND = ...

-- Add-on table.
--
local api = select(2, ...)

-- Extra padding for the minimap radius.
--
local MINIMAP_EXTRA_RADIUS = 5

-- FastbindMinimapButtonMixin declaration.
--
FastbindMinimapButtonMixin = {}

function FastbindMinimapButtonMixin:OnLoad()
	self:SetFixedFrameStrata(true)
	self:SetFixedFrameLevel(true)
	self:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
	self:RegisterEvent("ADDON_LOADED")

	self.isMouseDown = false
	self.position = 0

	-- In Mainline the icon falls one point short.
	if select(4, GetBuildInfo()) > 100000 then
		self.icon:SetSize(21, 21)
	end
end

function FastbindMinimapButtonMixin:OnEvent(event, ...)
	if event == "ADDON_LOADED" then
		local name = ...

		if name == FASTBIND then
			self.position = api.GetSavedVar("minimapButtonPosition")
			self:Update()
		end
	end
end

function FastbindMinimapButtonMixin:OnEnter()
	api.Printf("Mouse enter.")

	self:Update()
end

function FastbindMinimapButtonMixin:OnLeave()
	api.Printf("Mouse leave.")

	if not self:IsDragging() then
		self.isMouseDown = false
	end

	self:Update()
end

function FastbindMinimapButtonMixin:OnMouseDown(button)
	api.Printf("Mouse down: '%s'.", button)

	self.isMouseDown = true

	self:Update()
end

function FastbindMinimapButtonMixin:OnMouseUp()
	api.Printf("Mouse up.")

	self.isMouseDown = false

	if IsShiftKeyDown() then
		api.SetSavedVar("debug", not api.GetSavedVar("debug"))
	else
		FastbindFrame:Activate()
	end

	self:Update()
end

function FastbindMinimapButtonMixin:OnDragStart()
	api.Printf("Drag started.")

	self.isMouseDown = true

	self:LockHighlight()
	self:Update()
end

function FastbindMinimapButtonMixin:OnDragStop()
	api.Printf("Drag stopped.")

	self.isMouseDown = false

	-- Save new position.
	api.SetSavedVar("minimapButtonPosition", self.position)

	self:UnlockHighlight()
	self:Update()
end

function FastbindMinimapButtonMixin:OnUpdate()
	if self:IsDragging() then
		local scale = Minimap:GetEffectiveScale()
		local mx, my = Minimap:GetCenter()
		local cx, cy = GetCursorPosition()

		cx = cx / scale
		cy = cy / scale

		self.position = math.deg(math.atan2(cy - my, cx - mx)) % 360

		self:Update()
	end

	self:UpdateTooltip()
end

function FastbindMinimapButtonMixin:UpdateTooltip()
	if self:IsDragging() then
		self.tooltip:Hide()
		return
	end

	if not self:IsMouseOver() then
		self.tooltip:Hide()
		return
	end

	api.Printf("Update tooltip.")

	self.tooltip:SetOwner(self, "ANCHOR_NONE")
	self.tooltip:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, 0)
	self.tooltip:SetText(FASTBIND)
	if IsShiftKeyDown() then
		self.tooltip:AddLine("Toggle debug mode.", GRAY_FONT_COLOR:GetRGB())
	end
	self.tooltip:Show()
end

function FastbindMinimapButtonMixin:Update()
	api.Printf("Update.")

	local radius = Minimap:GetWidth() / 2 + MINIMAP_EXTRA_RADIUS
	local rads = math.rad(self.position)
	local x, y = math.cos(rads) * radius, math.sin(rads) * radius
	self:SetPoint("CENTER", Minimap, "CENTER", x, y)

	-- Push effect.
	if self.isMouseDown then
		self.icon:SetTexCoord(0, 1, 0, 1)
	else
		self.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
	end

	self:UpdateTooltip()
end
