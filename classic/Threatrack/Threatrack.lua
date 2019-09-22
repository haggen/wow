-- Threatrack
-- MIT License © 2019 Arthur Corenzan
-- More on https://github.com/haggen/wow

-- Constants.
--
local UNKNOWN = "UNKNOWN";
local HOSTILE = "HOSTILE";
local FRIENDLY = "FRIENDLY";

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

-- Gap between portraits.
--
local GUTTER = 8;

-- Coordinates for cropping race/class texture maps.
--
local PORTRAIT_TEXTURE_COORDS = {
    [TAUREN] = {0, 0.125, 0.25, 0.5},
    [SCOURGE] = {0.125, 0.25, 0.25, 0.5},
    [TROLL] = {0.25, 0.375, 0.25, 0.5},
    [ORC] = {0.375, 0.5, 0.25, 0.5},
    [HUMAN] = {0, 0.125, 0, 0.25},
    [DWARF] = {0.125, 0.25, 0, 0.25},
    [GNOME] = {0.25, 0.375, 0, 0.25},
    [NIGHTELF] = {0.375, 0.5, 0, 0.25},
    [WARRIOR] = {0, 0.25, 0, 0.25},
    [MAGE] = {0.25, 0.5, 0, 0.25},
    [ROGUE] = {0.5, 0.75, 0, 0.25},
    [DRUID] = {0.75, 1, 0, 0.25},
    [HUNTER] = {0, 0.25, 0.25, 0.5},
    [SHAMAN] = {0.25, 0.5, 0.25, 0.5},
    [PRIEST] = {0.5, 0.75, 0.25, 0.5},
    [WARLOCK] = {0.75, 1, 0.25, 0.5},
    [PALADIN] = {0, 0.25, 0.5, 0.75},
};

-- Textues for portrait race/class.
--
local UNKNOWN_TEXTURE = "Interface/TutorialFrame/UI-Help-Portrait";
local PORTRAIT_CLASSES_TEXTURE = "Interface/TargetingFrame/UI-Classes-Circles";
local PORTRAIT_RACES_TEXTURE = "Interface/Glues/CharacterCreate/UI-CharacterCreate-RacesRound";

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
    elseif (data.level < 0) then
        self.Skull:Show();
    elseif (data.level > 0) then
        self.Level:Show();
        self.Level:SetText(data.level);
    elseif (data.estimatedLevel > 0) then
        self.Level:Show();
        self.Level:SetText(string.format("%d+", data.estimatedLevel));
    else
        self.Level:Show();
        self.Level:SetText("??");
    end

    if (data.class ~= UNKNOWN) then
        self.Class:SetTexture(PORTRAIT_CLASSES_TEXTURE);
        self.Class:SetTexCoord(unpack(PORTRAIT_TEXTURE_COORDS[data.class]));
    else
        self.Class:SetTexture(UNKNOWN_TEXTURE);
        self.Class:SetTexCoord(0, 1, 0, 1);
    end

    -- if (data.race ~= UNKNOWN) then
    --     self.Race:SetTexture(UNKNOWN_TEXTURE);
    --     self.Race:SetTexCoord(0, 0, 0, 0);
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

--
--
--

Threatrack = {};

local SORTING_RANK = {
    [WARRIOR] = 1,
    [PALADIN] = 2,
    [ROGUE] = 3,
    [HUNTER] = 4,
    [PRIEST] = 5,
    [MAGE] = 6,
    [WARLOCK] = 7,
    [SHAMAN] = 8,
    [DRUID] = 9,
    [UNKNOWN] = 10,
};

local function SortPresenceData(a, b)
    if (a.class and b.class) then
        return SORTING_RANK[a.class] < SORTING_RANK[b.class];
    elseif (a.class) then
        return true;
    end
    return false;
end

local function StackPresenceData(data)
    local stackedData = {};
    for i = 1, #data do
        local playerClass = data[i].class;
        if (stackedData[playerClass]) then
            table.insert(stackedData[playerClass].stack, data[i]);
        else
            stackedData[playerClass] = {
                class = playerClass,
                stack = {data[i]},
            };
            -- stackedData is a numbered as well as associative table,
            -- we use hash maps to quickly check and gain access, but
            -- we also insert in a numbered position to be able to more
            -- easily sort and manipulate it later on.
            table.insert(stackedData, stackedData[playerClass]);
        end
    end
    return stackedData;
end

function Threatrack:GetPresenceData()
    local data = Threatrack_GetFreshPresenceData();
    -- local hostilePresenceData = {};
    -- for i = 1, #data do
    --     if (data[i].reaction == "hostile") then
    --         table.insert(hostilePresenceData, data[i]);
    --     end
    -- end

    if (#data > #self.portraits) then
        data = StackPresenceData(data);
    end

    table.sort(data, SortPresenceData);
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

    Threatrack_HandleNewPresence(function()
        self:Update();
    end);
end
