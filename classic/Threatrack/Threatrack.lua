-- Threatrack
-- MIT License © 2019 Arthur Corenzan
-- More on https://github.com/haggen/wow

UIParentLoadAddOn("Blizzard_DebugTools");

--
--
--

-- Threatrack
-- MIT License © 2019 Arthur Corenzan
-- More on https://github.com/haggen/wow

-- local textureCoordsForRace = {
--     tauren = {0, 0.125, 0.25, 0.5},
--     scourge = {0.125, 0.25, 0.25, 0.5},
--     troll = {0.25, 0.375, 0.25, 0.5},
--     orc = {0.375, 0.5, 0.25, 0.5},
--     human = {0, 0.125, 0, 0.25},
--     dwarf = {0.125, 0.25, 0, 0.25},
--     gnome = {0.25, 0.375, 0, 0.25},
--     nightelf = {0.375, 0.5, 0, 0.25},
-- };

local textureCoordsForClass = {
    warrior = {0, 0.25, 0, 0.25},
    mage = {0.25, 0.5, 0, 0.25},
    rogue = {0.5, 0.75, 0, 0.25},
    druid = {0.75, 1, 0, 0.25},
    hunter = {0, 0.25, 0.25, 0.5},
    shaman = {0.25, 0.5, 0.25, 0.5},
    priest = {0.5, 0.75, 0.25, 0.5},
    warlock = {0.75, 1, 0.25, 0.5},
    paladin = {0, 0.25, 0.5, 0.75},
};

local textureClasses = "Interface/TargetingFrame/UI-Classes-Circles";
local textureUnkown = "Interface/TutorialFrame/UI-Help-Portrait";
-- local textureRaces = "Interface/Glues/CharacterCreate/UI-CharacterCreate-RacesRound";

--
--
--

ThreatrackPortrait = {};

function ThreatrackPortrait:Update(data)
    self.data = data;

    if (data.level) then
        if (data.level < 0) then
            self.Level:Hide();
            self.Skull:Show();
        else
            self.Skull:Hide();
            self.Level:Show();
            self.Level:SetText(data.level);
        end
    elseif (data.minLevel) then
        self.Skull:Hide();
        self.Level:Show();
        self.Level:SetText(string.format(" %d+", data.minLevel));
    else
        self.Skull:Hide();
        self.Level:Show();
        self.Level:SetText("??");
    end

    if (data.class) then
        self.Class:SetTexture(textureClasses);
        self.Class:SetTexCoord(unpack(textureCoordsForClass[data.class]));
    else
        self.Class:SetTexture(textureUnkown);
        self.Class:SetTexCoord(0, 1, 0, 1);
    end

    -- if (data.race ~= "") then
    --     self.Race:SetTexture(textureUnkown);
    --     self.Race:SetTexCoord(0, 0, 0, 0);
    -- else
    --     self.Race:SetTexture(textureRaces);
    --     self.Race:SetTexCoord(unpack(textureCoordsForRace[data.race]));
    -- end
end

function ThreatrackPortrait:OnUpdate()
    if (self:IsShown() and Threatrack_IsPresenceStale(self.data)) then
        Threatrack:Update();
    end
end

--
--
--

local portraitGutter = 8;

Threatrack = {};

local function SortPresenceData(a, b)
    if (a.class and b.class) then
        return a.class < b.class;
    elseif (a.class) then
        return true;
    end
    return false;
end

function Threatrack:GetPresenceData()
    local allPresenceData = Threatrack_GetPresenceData();
    -- local hostilePresenceData = {};
    -- for i = 1, #allPresenceData do
    --     if (allPresenceData[i].reaction == "hostile") then
    --         table.insert(hostilePresenceData, allPresenceData[i]);
    --     end
    -- end
    table.sort(allPresenceData, SortPresenceData);
    return allPresenceData;
end

function Threatrack:Update()
    local playerPresenceData = self:GetPresenceData();

    self:SetWidth(0);

    for i = 1, #self.portraits do
        local portrait = self.portraits[i];
        local data = playerPresenceData[i];

        portrait:ClearAllPoints();
        portrait:Hide();

        if data then
            portrait:Update(data);
            portrait:Show();

            if (i > 1) then
                portrait:SetPoint("LEFT", self.portraits[i - 1], "RIGHT", portraitGutter, 0);
                self:SetWidth(self:GetWidth() + portraitGutter + portrait:GetWidth());
            else
                portrait:SetPoint("LEFT", self);
                self:SetWidth(portrait:GetWidth());
            end
        end
    end
end

function Threatrack:OnLoad()
    Threatrack = self;

    Threatrack_HandlePresence(function()
        self:Update();
    end);
end
