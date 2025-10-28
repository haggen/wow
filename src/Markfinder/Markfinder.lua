-- Add-on name and context.
local MARKFINDER, ctx = ...;

-- Macro tag to identify the Markfinder macro.
local MACRO_TAG = "#markfinder";

-- Macro source template.
local TEMPLATE = string.format([[
%s
/cleartarget
/target %%s
/script SetRaidTarget("target", 1);
]], MACRO_TAG);

-- Target command pattern and replacement.
local TARGET_CMD_PATTERN = "/target .-(%f[%z\n])";
local TARGET_CMD_REPLACEMENT = "/target %s%%1";

-- Macro icon.
local SPYGLASS_ICON_ID = 134442;

-- Find the Markfinder macro and return its info or nil.
local function GetMarkfinderMacroInfo()
    local _, count = GetNumMacros();

    for idx = MAX_ACCOUNT_MACROS + 1, MAX_ACCOUNT_MACROS + count do
        local name, icon, src = GetMacroInfo(idx);

        if string.find(src, MACRO_TAG) == 1 then
            return idx, name, icon, src;
        end
    end

    return nil;
end

-- Create the Markfinder macro.
local function CreateMarkfinderMacro()
    local _, count = GetNumMacros();

    if count >= MAX_CHARACTER_MACROS then
        ctx.Announce(string.format("Couldn't create the macro because you can't have more than %d character specific macros.", MAX_CHARACTER_MACROS));
        return;
    end

    local name = UnitName("player");

    ctx.OutOfCombat(function()
        CreateMacro(MARKFINDER, SPYGLASS_ICON_ID, string.format(TEMPLATE, name), true);
    end);
end

-- Update the target command in the Markfinder macro.
local function EditMarkfinderMacro(query)
    local idx, name, icon, src = GetMarkfinderMacroInfo();

    if not idx then
        ctx.Announce(string.format("Couldn't find a macro tagged with %s.", MACRO_TAG));
        return;
    end

    if not string.find(src, TARGET_CMD_PATTERN) then
        ctx.Announce("Couldn't find a /target command in the Markfinder macro.");
        return;
    end

    ctx.OutOfCombat(function()
        EditMacro(idx, name, icon, string.gsub(src, TARGET_CMD_PATTERN, string.format(TARGET_CMD_REPLACEMENT, query)));
    end);
end

-- Wait for the macro system to be ready to create the macro.
ctx.frame:RegisterEvent("PLAYER_ENTERING_WORLD");
ctx.frame:OnEvent("PLAYER_ENTERING_WORLD", function()
    if not GetMarkfinderMacroInfo() then
        CreateMarkfinderMacro();
    end
end);

-- Hook into TargetUnit function to update the macro.
hooksecurefunc("TargetUnit", function (query)
    if query == "mouseover" then
        return;
    end

    EditMarkfinderMacro(query);
end);
