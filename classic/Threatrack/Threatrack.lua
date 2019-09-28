-- Threatrack
-- MIT License © 2019 Arthur Corenzan
-- More on https://github.com/haggen/wow

-- Constants.
--
local UNKNOWN = "UNKNOWN";
-- local HOSTILE = "HOSTILE";
local FRIENDLY = "FRIENDLY";
local SKULL = -1;

local DWARF = "DWARF";
local GNOME = "GNOME";
local HUMAN = "HUMAN";
local NIGHTELF = "NIGHTELF";
local ORC = "ORC";
local SCOURGE = "SCOURGE";
local TAUREN = "TAUREN";
local TROLL = "TROLL";
local DRUID = "DRUID";
local HUNTER = "HUNTER";
local MAGE = "MAGE";
local PALADIN = "PALADIN";
local PRIEST = "PRIEST";
local ROGUE = "ROGUE";
local SHAMAN = "SHAMAN";
local WARLOCK = "WARLOCK";
local WARRIOR = "WARRIOR";

-- Used for display.
-- TODO: In the future this should be translatable.
local PRETTY_NAMES = {
    [DWARF] = "Dwarf";
    [GNOME] = "Gnome";
    [HUMAN] = "Human";
    [NIGHTELF] = "Night Elf";
    [ORC] = "Orc";
    [SCOURGE] = "Undead";
    [TAUREN] = "Tauren";
    [TROLL] = "Troll";
    [DRUID] = "Druid";
    [HUNTER] = "Hunter";
    [MAGE] = "Mage";
    [PALADIN] = "Paladin";
    [PRIEST] = "Priest";
    [ROGUE] = "Rogue";
    [SHAMAN] = "Shaman";
    [WARLOCK] = "Warlock";
    [WARRIOR] = "Warrior";
}

-- Gap between portraits.
--
local GUTTER = 8;

-- Coordinates for cropping race/class texture maps.
--
local PORTRAIT_TEXTURE_COORDS = {
    -- Races.
    [HUMAN]    = {0.005859375, 0.119140625, 0.01171875, 0.23828125},
    [DWARF]    = {0.130859375, 0.244140625, 0.01171875, 0.23828125},
    [GNOME]    = {0.255859375, 0.369140625, 0.01171875, 0.23828125},
    [NIGHTELF] = {0.380859375, 0.494140625, 0.01171875, 0.23828125},
    [TAUREN]   = {0.005859375, 0.119140625, 0.26171875, 0.48828125},
    [SCOURGE]  = {0.130859375, 0.244140625, 0.26171875, 0.48828125},
    [TROLL]    = {0.255859375, 0.369140625, 0.26171875, 0.48828125},
    [ORC]      = {0.380859375, 0.494140625, 0.26171875, 0.48828125},
    [UNKNOWN]  = {0.000000000, 0.921875000, 0.00000000, 0.92187500},
    -- Classes.
    [WARRIOR]  = {0.011718750, 0.238281250, 0.01171875, 0.23828125},
    [MAGE]     = {0.257812500, 0.484375000, 0.01171875, 0.23828125},
    [ROGUE]    = {0.503906250, 0.730468750, 0.01171875, 0.23828125},
    [DRUID]    = {0.750000000, 0.976562500, 0.01171875, 0.23828125},
    [HUNTER]   = {0.011718750, 0.238281250, 0.26171875, 0.48828125},
    [SHAMAN]   = {0.257812500, 0.484375000, 0.26171875, 0.48828125},
    [PRIEST]   = {0.503906250, 0.730468750, 0.26171875, 0.48828125},
    [WARLOCK]  = {0.753906250, 0.980468750, 0.26171875, 0.48828125},
    [PALADIN]  = {0.011718750, 0.238281250, 0.51171875, 0.73828125},
    [UNKNOWN]  = {0.000000000, 0.921875000, 0.00000000, 0.92187500},
};

-- Textues for portrait race/class.
--
local UNKNOWN_TEXTURE = "Interface/TutorialFrame/UI-Help-Portrait";
local PORTRAIT_CLASSES_TEXTURE = "Interface/TargetingFrame/UI-Classes-Circles";
-- local PORTRAIT_RACES_TEXTURE = "Interface/Glues/CharacterCreate/UI-CharacterCreate-RacesRound";

--
--
--

-- Portrait mixin.
--
ThreatrackPortrait = {};

-- Update portrait Class icon.
--
local function UpdatePortraitClassTexture(portrait, data)
    if (data.class == UNKNOWN) then
        portrait.Class:SetTexture(UNKNOWN_TEXTURE);
    else
        portrait.Class:SetTexture(PORTRAIT_CLASSES_TEXTURE);
    end
    portrait.Class:SetTexCoord(unpack(PORTRAIT_TEXTURE_COORDS[data.class]));
end

-- Update portrait Race icon.
--
-- local function UpdatePortraitRaceTexture(portrait, data)
--     if (data.race == UNKNOWN) then
--         portrait.Race:SetTexture(UNKNOWN_TEXTURE);
--     else
--         portrait.Race:SetTexture(PORTRAIT_RACES_TEXTURE);
--     end
--     portrait.Race:SetTexCoord(unpack(PORTRAIT_TEXTURE_COORDS[data.race]));
-- end

-- Tell whether the Skull icon should be displayed given a player's level information.
--
local function ShouldDisplaySkullLevel(data)
    if (data.effectiveLevel == SKULL) then
        return data.estimatedLevel < UnitLevel("player") + 10;
    end
    return false;
end

-- Format player level's information to be displayed.
--
local function GetDisplayLevel(data)
    if (data.effectiveLevel > 0) then
        return tostring(data.effectiveLevel);
    end
    if (data.estimatedLevel > 0) then
        return string.format("%d+", data.estimatedLevel);
    end
    return "??";
end

-- Update portrait frame given stacked data, i.e. non-flat.
--
local function UpdateStackedPortrait(portrait, data)
    portrait.Level:Show();
    portrait.Level:SetText(string.format("×%d", #data.stack));

    UpdatePortraitClassTexture(portrait, data);
end

-- Update portrait frame given flat data, i.e. non-stacked.
--
local function UpdateFlatPortrait(portrait, data)
    if ShouldDisplaySkullLevel(data) then
        portrait.Skull:Show()
    else
        portrait.Level:Show();
        local displayLevel = GetDisplayLevel(data);
        -- Small tweak to fix text alignment problems due to the font not being fixed width.
        if string.find(displayLevel, "[2-6]%d?%+") then
            displayLevel = " "..displayLevel;
        end
        portrait.Level:SetText(displayLevel);
    end

    UpdatePortraitClassTexture(portrait, data);
end

-- Update portrait.
--
function ThreatrackPortrait:Update(data)
    self.data = data;

    self.Skull:Hide();
    self.Level:Hide();

    if (data.stack) then
        UpdateStackedPortrait(self, data);
    else
        UpdateFlatPortrait(self, data);
    end
end

-- Portrait OnUpdate handler. We use it to request an update once the data becomes stale.
--
function ThreatrackPortrait:OnUpdate()
    if (not self:IsShown()) then
        return nil;
    end

    if (self.data.stack) then
        local stack = self.data.stack;
        for i = 1, #stack do
            if Threatrack_IsPresenceStale(stack[i]) then
                Threatrack:Update();
                return nil;
            end
        end
    else
        if Threatrack_IsPresenceStale(self.data) then
            Threatrack:Update();
        end
    end
end

-- ...
--
local function SetStackedPortraitTooltip(data)
    GameTooltip:SetText(PRETTY_NAMES[data.class]);

    for i = 1, #data.stack do
        local details = string.format("Level %s %s", GetDisplayLevel(data.stack[i]), PRETTY_NAMES[data.stack[i].race]);
        GameTooltip:AddDoubleLine(data.stack[i].name, details, 1, 1, 1, 1, 1, 1);
    end
end

-- ...
--
local function SetFlatPortraitTooltip(data)
    local details = string.format("Level %s %s %s", GetDisplayLevel(data), PRETTY_NAMES[data.race], PRETTY_NAMES[data.class]);
    GameTooltip:SetText(data.name);
    GameTooltip:AddLine(details, 1, 1, 1);
end

-- Portrait OnEnter handler. Used to display tooltip.
--
function ThreatrackPortrait:OnEnter()
    GameTooltip:ClearAllPoints();
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -8);

    if (self.data.stack) then
        SetStackedPortraitTooltip(self.data);
    else
        SetFlatPortraitTooltip(self.data);
    end

    GameTooltip:Show();
end

-- Portrait OnEnter handler. Used to hide the tooltip.
--
function ThreatrackPortrait:OnLeave()
    GameTooltip:Hide();
end

--
--
--

Threatrack = {};

local function SortStackedPresenceData(a, b)
    return #a.stack > #b.stack;
end

local function StackPresenceData(data)
    local stackedData = {};
    for i = 1, #data do
        local playerClass = data[i].class;

        if (stackedData[playerClass] == nil) then
            stackedData[playerClass] = {
                class = playerClass,
                stack = {data[i]},
            };
            -- stackedData is a numbered as well as associative table,
            -- we use hash maps to quickly check and gain access, but
            -- we also insert in a numbered position to be able to more
            -- easily sort and manipulate it later on.
            table.insert(stackedData, stackedData[playerClass]);
        else
            table.insert(stackedData[playerClass].stack, data[i]);
        end
    end
    return stackedData;
end

local function SortFlatPresenceData(a, b)
    return a.lastDetectionTime < b.lastDetectionTime;
end

function Threatrack:GetPresenceData()
    local data = Threatrack_GetFreshPlayerData();

    if (ThreatrackSavedVars.options.ignoreFriendlyPresence) then
        local filteredData = {};
        for i = 1, #data do
            if (data[i].reaction ~= FRIENDLY) then
                table.insert(filteredData, data[i]);
            end
        end
        data = filteredData;
    end

    if (#data > #self.portraits) then
        data = StackPresenceData(data);
        table.sort(data, SortStackedPresenceData);
    else
        table.sort(data, SortFlatPresenceData);
    end

    return data;
end

function Threatrack:Update()
    local presenceData = self:GetPresenceData();

    self:SetWidth(0);

    for i = 1, #self.portraits do
        local portrait = self.portraits[i];
        local data = presenceData[i];

        portrait:ClearAllPoints();
        portrait:Hide();

        if data then
            portrait:Update(data);
            portrait:Show();

            if (i > 1) then
                portrait:SetPoint("LEFT", self.portraits[i - 1], "RIGHT", GUTTER, 0);
                self:SetWidth(self:GetWidth() + GUTTER + portrait:GetWidth());
            else
                portrait:SetPoint("LEFT", self);
                self:SetWidth(portrait:GetWidth());
            end
        end
    end
end

function Threatrack:OnLoad()
    Threatrack = self;

    -- BreathBar default position overlaps with the portraits.
    -- FrameXML/MirrorTimer.xml:80
    MirrorTimer1:ClearAllPoints();
    MirrorTimer1:SetPoint("TOP", 0, -104);

    Threatrack_HandlePlayerPresence(function()
        self:Update();
    end);
end

--
--
--

ThreatrackSavedVars = {
    options = {
        ignoreFriendlyPresence = true
    }
};
