-- Fastbind
-- The MIT License © 2017 Arthur Corenzan
-- More on https://github.com/haggen/wow

--- Add-on name constant.
--- @type "Fastbind"
---
local FASTBIND = ...

--- @class API
---
local api = select(2, ...)

--- Extra padding for the distance between the minimap center and the button.
---
local MINIMAP_RADIUS_PADDING = 5

--- FastbindMinimapButtonMixin declaration.
--- @class FastbindMinimapButtonMixin: Button
--- @field icon Texture
---
FastbindMinimapButtonMixin = {}

function FastbindMinimapButtonMixin:OnLoad()
    self:SetFixedFrameStrata(true)
    self:SetFixedFrameLevel(true)
    self:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    self:UpdatePosition()
    self:RegisterEvent("ADDON_LOADED")
end

function FastbindMinimapButtonMixin:OnEvent(event, ...)
    if event == "ADDON_LOADED" then
        local name = ...

        if name == FASTBIND then
            self:UpdatePosition()
        end
    end
end

function FastbindMinimapButtonMixin:OnEnter()
    api.Printf("Mouse enter.")

    if self:IsDragging() then
        return
    end
    self:ShowTooltip()
end

function FastbindMinimapButtonMixin:OnLeave()
    api.Printf("Mouse leave.")

    if self:IsDragging() then
        return
    end
    self:HideTooltip()
end

function FastbindMinimapButtonMixin:OnMouseDown()
    api.Printf("Mouse down.")

    self:Push()
end

function FastbindMinimapButtonMixin:OnMouseUp()
    api.Printf("Mouse up.")

    self:Release()

    if IsShiftKeyDown() then
        api.SetSavedVar("debug", not api.GetSavedVar("debug"))
    else
        --- @diagnostic disable-next-line: undefined-global
        FastbindFrame:Activate()
    end
end

function FastbindMinimapButtonMixin:OnDragStart()
    api.Printf("Drag started.")

    self:SetScript("OnUpdate", self.OnUpdate)
    self:LockHighlight()
    self:HideTooltip()
end

function FastbindMinimapButtonMixin:OnDragStop()
    api.Printf("Drag stopped.")

    self:SetScript("OnUpdate", nil)
    self:UnlockHighlight()
    self:Release()

    --- @diagnostic disable-next-line: missing-parameter
    if self:IsMouseOver() then
        self:ShowTooltip()
    end
end

function FastbindMinimapButtonMixin:OnUpdate()
    local scale = Minimap:GetEffectiveScale()
    local mx, my = Minimap:GetCenter()
    local cx, cy = GetCursorPosition()

    cx = cx / scale
    cy = cy / scale

    api.SetSavedVar("minimapButtonPosition", math.deg(math.atan2(cy - my, cx - mx)) % 360)

    self:UpdatePosition()
end

function FastbindMinimapButtonMixin:ShowTooltip()
    GameTooltip:SetOwner(self, "ANCHOR_NONE")
    GameTooltip:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, 0)
    if IsShiftKeyDown() then
        GameTooltip:SetText("Toggle debug mode.", 1, 1, 1)
    else
        GameTooltip:SetText(FASTBIND)
    end
    GameTooltip:Show()
end

function FastbindMinimapButtonMixin:HideTooltip()
    GameTooltip:Hide()
end

function FastbindMinimapButtonMixin:UpdatePosition()
    local radius = Minimap:GetWidth() / 2 + MINIMAP_RADIUS_PADDING
    local rads = math.rad(api.GetSavedVar("minimapButtonPosition"))
    local x, y = math.cos(rads) * radius, math.sin(rads) * radius
    self:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

function FastbindMinimapButtonMixin:Push()
    self.icon:SetTexCoord(0, 1, 0, 1)
end

function FastbindMinimapButtonMixin:Release()
    self.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
end
