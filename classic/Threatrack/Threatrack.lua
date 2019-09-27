-- Threatrack
-- MIT License © 2019 Arthur Corenzan
-- More on https://github.com/haggen/wow

-- Constants.
--
local UNKNOWN = "UNKNOWN";
local HOSTILE = "HOSTILE";
-- local FRIENDLY = "FRIENDLY";

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
    [HUMAN] = {0.005859375, 0.119140625, 0.01171875, 0.23828125},
    [DWARF] = {0.130859375, 0.244140625, 0.01171875, 0.23828125},
    [GNOME] = {0.255859375, 0.369140625, 0.01171875, 0.23828125},
    [NIGHTELF] = {0.380859375, 0.494140625, 0.01171875, 0.23828125},
    [TAUREN] = {0.005859375, 0.119140625, 0.26171875, 0.48828125},
    [SCOURGE] = {0.130859375, 0.244140625, 0.26171875, 0.48828125},
    [TROLL] = {0.255859375, 0.369140625, 0.26171875, 0.48828125},
    [ORC] = {0.380859375, 0.494140625, 0.26171875, 0.48828125},

    [WARRIOR] = {0.01171875, 0.23828125, 0.01171875, 0.23828125},
    [MAGE] = {0.2578125, 0.484375, 0.01171875, 0.23828125},
    [ROGUE] = {0.50390625, 0.73046875, 0.01171875, 0.23828125},
    [DRUID] = {0.75, 0.9765625, 0.01171875, 0.23828125},
    [HUNTER] = {0.01171875, 0.23828125, 0.26171875, 0.48828125},
    [SHAMAN] = {0.2578125, 0.484375, 0.26171875, 0.48828125},
    [PRIEST] = {0.50390625, 0.73046875, 0.26171875, 0.48828125},
    [WARLOCK] = {0.75390625, 0.98046875, 0.26171875, 0.48828125},
    [PALADIN] = {0.01171875, 0.23828125, 0.51171875, 0.73828125},
};

-- Textues for portrait race/class.
--
local UNKNOWN_TEXTURE = "Interface/TutorialFrame/UI-Help-Portrait";
local PORTRAIT_CLASSES_TEXTURE = "Interface/TargetingFrame/UI-Classes-Circles";
-- local PORTRAIT_RACES_TEXTURE = "Interface/Glues/CharacterCreate/UI-CharacterCreate-RacesRound";

--
--
--

ThreatrackPortrait = {};

function ThreatrackPortrait:Update(data)
    self.data = data;

    self.Skull:Hide();
    self.Level:Hide();

    if (data.stack) then
        self.Level:Show();
        self.Level:SetText(string.format("×%d", #data.stack));
    elseif (data.effectiveLevel < 0) then
        self.Skull:Show();
    elseif (data.effectiveLevel > 0) then
        self.Level:Show();
        self.Level:SetText(data.effectiveLevel);
    elseif (data.estimatedLevel > 0) then
        self.Level:Show();
        self.Level:SetText(string.format(" %d+", data.estimatedLevel));
    else
        self.Level:Show();
        self.Level:SetText("??");
    end

    if (data.class == UNKNOWN) then
        self.Class:SetTexture(UNKNOWN_TEXTURE);
        self.Class:SetTexCoord(0, 0.921875, 0, 0.921875);
    else
        self.Class:SetTexture(PORTRAIT_CLASSES_TEXTURE);
        self.Class:SetTexCoord(unpack(PORTRAIT_TEXTURE_COORDS[data.class]));
    end

    -- if (data.race == UNKNOWN) then
    --     self.Race:SetTexture(UNKNOWN_TEXTURE);
    --     self.Race:SetTexCoord(0, 0.921875, 0, 0.921875);
    -- else
    --     self.Race:SetTexture(PORTRAIT_RACES_TEXTURE);
    --     self.Race:SetTexCoord(unpack(PORTRAIT_TEXTURE_COORDS[data.race]));
    -- end
end

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

function ThreatrackPortrait:OnEnter()
    GameTooltip:ClearAllPoints();
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -8);
    if (self.data.stack) then
        GameTooltip:SetText(PRETTY_NAMES[self.data.class]);
        for i = 1, #self.data.stack do
            local data = self.data.stack;
            local level = data[i].effectiveLevel;
            if (level < 1) then
                if (data[i].estimatedLevel > 0) then
                    level = string.format("%d+", data[i].estimatedLevel);
                else
                    level = "??";
                end
            end
            GameTooltip:AddDoubleLine(data[i].name, string.format("Level %s %s", level, PRETTY_NAMES[data[i].race]), 1, 1, 1, 1, 1, 1);
        end
    else
        local level = self.data.effectiveLevel;
        if (level < 1) then
            if (self.data.estimatedLevel > 0) then
                level = string.format("%d+", self.data.estimatedLevel);
            else
                level = "??";
            end
        end
        GameTooltip:SetText(self.data.name);
        GameTooltip:AddLine(string.format("Level %s %s %s", level, PRETTY_NAMES[self.data.race], PRETTY_NAMES[self.data.class]), 1, 1, 1);
    end

    GameTooltip:Show();
end

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
        local hostilePresenceData = {};
        for i = 1, #data do
            if (data[i].reaction == HOSTILE) then
                table.insert(hostilePresenceData, data[i]);
            end
        end
        data = hostilePresenceData;
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
