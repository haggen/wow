--- Add-on name.
---@type string
local TARGETRIGGER = ...

--- Update or create the macro based on the message typed in chat.
---@param message string
local function UpsertMacro(message)
    if not message:match("^/tar ") and not message:match("^/target ") then
        return
    end

    local macro = message .. "\n/tm [exists,nodead]4"

    local macroIdx = GetMacroIndexByName(TARGETRIGGER)
    if macroIdx == 0 then
        local num = GetNumMacros()
        if num == Constants.MacroConsts.MAX_ACCOUNT_MACROS then
            print(string.format("|cffff0000%s|r: There aren't any available slots for account macros.", TARGETRIGGER))
            return
        end

        CreateMacro(TARGETRIGGER, "Interface\\Icons\\Inv_111_redbutton_bilgewater", macro, nil)
    else
        EditMacro(macroIdx, nil, nil, macro)
    end
end

--- Hooked edit boxes.
---@type table<EditBox, boolean>
local registry = {}

--- Hook the edit box, if it hasn't been hooked yet.
---@param editBox EditBox
local function HookEditBox(editBox)
    if registry[editBox] then
        return
    end

    hooksecurefunc(editBox, "AddHistoryLine", function(self, text)
        WhenOutOfCombat(UpsertMacro, text)
    end)

    registry[editBox] = true
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("UPDATE_CHAT_WINDOWS")
frame:SetScript("OnEvent", function()
    -- All the other chat hooks happen BEFORE slash commands are processed so this is how I managed:
    for i = 1, NUM_CHAT_WINDOWS do
        local editBox = _G["ChatFrame" .. i .. "EditBox"]
        if editBox then
            HookEditBox(editBox)
        end
    end
end)
