--- Add-on name.
---@type string
local PRESSIGHT = ...

--- Icon size.
local ICON_SIZE = 12

--- Gap between icons.
local ICON_GAP = 1

--- Update interval.
local UPDATE_INTERVAL = 0.1

--- Ability entry.
---@class Ability
---@field spellId number Spell ID.
---@field iconId number Icon ID.
---@field name string Ability name.
---@field range number[] Min and max range.

--- Abilities table.
---@alias Abilities table<string, Ability>

--- Abilities table.
---@type Abilities
local abilities = {}

--- Register ability.
---@param abilities table<string, Ability>
---@param ability Ability
local function RegisterAbility(abilities, ability)
    local key = ability.name
    if not abilities[key] then
        abilities[key] = ability
    end
end

--- Rebuild abilities table.
---@param abilities table<string, Ability>
local function RebuildAbilities(abilities)
    for key in pairs(abilities) do
        abilities[key] = nil
    end

    for _, bankIdx in pairs(Enum.SpellBookSpellBank) do
        local lines = C_SpellBook.GetNumSpellBookSkillLines(bankIdx) or 0

        for lineIdx = 1, lines do
            local line = C_SpellBook.GetSpellBookSkillLineInfo(lineIdx, bankIdx)

            if line and line.numSpellBookItems > 0 then
                local offset = line.itemIndexOffset
                local items = line.numSpellBookItems

                for itemIdx = 1, items do
                    local item = C_SpellBook.GetSpellBookItemInfo(offset + itemIdx, bankIdx)

                    if item and not item.isPassive and not item.isOffSpec then
                        local spellId = item.actionID or item.spellID

                        if spellId then
                            local spell = C_Spell.GetSpellInfo(spellId)

                            if spell then
                                RegisterAbility(abilities, {
                                    spellId = spell.spellID,
                                    name = spell.name,
                                    range = { spell.minRange or 0, spell.maxRange or 0 },
                                    iconId = spell.iconID,
                                })
                            end
                        end
                    end
                end
            end
        end
    end
end

--
--
--

PressightFrameMixin = {}

--- Initialize the frame.
function PressightFrameMixin:OnLoad()
    self.pool = CreateTexturePool(self, "ARTWORK", 0, "PressightIcon")
    self.elapsed = 0
end

--- Get the nameplate associated with the frame.
function PressightFrameMixin:GetNamePlate()
    return self:GetParent()
end

--- Get the unit associated with the frame.
function PressightFrameMixin:GetUnit()
    return self:GetNamePlate():GetUnit()
end

--- Determine if the ability should be shown on the nameplate.
---@param ability Ability
---@param unit string
function PressightFrameMixin:DetermineIconVisibility(ability, unit)
    return C_Spell.IsSpellUsable(ability.spellId) and C_Spell.IsSpellInRange(ability.spellId, unit)
end

--- Refresh the frame and its icons.
function PressightFrameMixin:Refresh()
    self.pool:ReleaseAll()

    local unit = self:GetUnit()
    if not unit then
        return
    end

    local count = 0

    for _, ability in pairs(abilities) do
        if self:DetermineIconVisibility(ability, unit) then
            count = count + 1

            local icon = self.pool:Acquire()
            icon:SetTexture(ability.iconId)
            icon:SetPoint("LEFT", self, "LEFT", (count - 1) * (ICON_SIZE + ICON_GAP), 0)
            icon:SetSize(ICON_SIZE, ICON_SIZE)
            icon:Show()
        end
    end

    if count > 0 then
        self:SetSize(count * (ICON_SIZE + ICON_GAP) - ICON_GAP, ICON_SIZE)
    end
end

--- OnUpdate script.
function PressightFrameMixin:OnUpdate(delta)
    self.elapsed = self.elapsed + delta
    if self.elapsed < UPDATE_INTERVAL then
        return
    end
    self.elapsed = 0

    self:Refresh()
end

--
--
--

local function UpgradeUnitNamePlate(plate)
    if not plate.PressightFrame then
        local frame = CreateFrame("Frame", nil, plate, "PressightFrame")
        frame:SetPoint("TOP", plate, "BOTTOM", 0, 0)
        frame:SetSize(ICON_SIZE, ICON_SIZE)

        plate.PressightFrame = frame
    end

    plate.PressightFrame:Refresh()
end

local frame = CreateFrame("Frame")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "NAME_PLATE_UNIT_ADDED" then
        local unit = ...
        local plate = C_NamePlate.GetNamePlateForUnit(unit)
        if plate then
            UpgradeUnitNamePlate(plate)
        end
    elseif event == "PLAYER_ENTERING_WORLD" or event == "SPELLS_CHANGED" then
        RebuildAbilities(abilities)

        local plates = C_NamePlate.GetNamePlates()
        for _, plate in ipairs(plates) do
            UpgradeUnitNamePlate(plate)
        end
    end
end)

-- NAME_PLATE_UNIT_ADDED fires when a nameplate is assigned to a unit.
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")

-- These two are used to keep the abilities table fresh.
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("SPELLS_CHANGED")
