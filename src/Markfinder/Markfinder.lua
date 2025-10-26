local MARKFINDER = "Markfinder";

local TEMPLATE = [[
#markfinder
/target %s
/script SetRaidTarget("target", 1);
]]

local function GetMarkfindMacroInfo()
    local _, count = GetNumMacros();
    for idx = MAX_ACCOUNT_MACROS + 1, MAX_ACCOUNT_MACROS + count do
        local name, icon, body = GetMacroInfo(idx);

        if string.find(body, "#markfind") == 1 then
            return idx, name, icon, body
        end
    end
    return nil
end

local function CreateMarkfindMacro()
    local name = UnitName("player");
    CreateMacro(MARKFINDER, 134442, string.format(TEMPLATE, name), true);
end

local function EditMarkfindMacro(q)
    local idx, name, icon, template = GetMarkfindMacroInfo();

    if not idx then
        print("Markfinder: Couldn't find a macro tagged with #markfind.")
        return;
    end

    local body = string.gsub(template, "/target .-(%f[%z\n])", string.format("/target %s%%1", q));

    if body == template then
        print("Markfinder: Couldn't find the /target command in the Markfinder macro.")
    end

    EditMacro(idx, name, icon, body);
end
    
local frame = CreateFrame("Frame");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        if not GetMarkfindMacroInfo() then
            CreateMarkfindMacro();
        end
    end
end);

hooksecurefunc("TargetUnit", function (q)
    EditMarkfindMacro(q);
end);
