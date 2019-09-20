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

local RACE_TEXTURE_COORDS = {
    TAUREN = {0, 0.125, 0.25, 0.5},
    SCOURGE = {0.125, 0.25, 0.25, 0.5},
    TROLL = {0.25, 0.375, 0.25, 0.5},
    ORC = {0.375, 0.5, 0.25, 0.5},
    HUMAN = {0, 0.125, 0, 0.25},
    DWARF = {0.125, 0.25, 0, 0.25},
    GNOME = {0.25, 0.375, 0, 0.25},
    NIGHTELF = {0.375, 0.5, 0, 0.25},
};

local CLASS_TEXTURE_COORDS = {
    WARRIOR = {0, 0.25, 0, 0.25},
    MAGE = {0.25, 0.5, 0, 0.25},
    ROGUE = {0.5, 0.75, 0, 0.25},
    DRUID = {0.75, 1, 0, 0.25},
    HUNTER = {0, 0.25, 0.25, 0.5},
    SHAMAN = {0.25, 0.5, 0.25, 0.5},
    PRIEST = {0.5, 0.75, 0.25, 0.5},
    WARLOCK = {0.75, 1, 0.25, 0.5},
    PALADIN = {0, 0.25, 0.5, 0.75},
};

--
--
--

ThreatrackPortrait = {};

function ThreatrackPortrait:Update(data)
    self.Level:SetText(data.level);
    self.Race:SetTexCoord(unpack(RACE_TEXTURE_COORDS[data.race]));
    self.Class:SetTexCoord(unpack(CLASS_TEXTURE_COORDS[data.class]));
end

function ThreatrackPortrait:OnLoad()
end

function ThreatrackPortrait:OnUpdate()
end

--
--
--

local PORTRAIT_GUTTER = 8;

Threatrack = {};

function Threatrack:Update()
    local detectedPlayers = Threatrack_GetDetectedPlayers();

    self:SetWidth(0);

    for i = 1, #self.portraits do
        local portrait = self.portraits[i];
        local data = detectedPlayers[i];

        portrait:ClearAllPoints();

        if data then
            portrait:Update(data);

            if (i > 1) then
                portrait:SetPoint("LEFT", self.portraits[i - 1], "RIGHT", PORTRAIT_GUTTER, 0);
                self:SetWidth(self:GetWidth() + PORTRAIT_GUTTER + portrait:GetWidth());
            else
                portrait:SetPoint("LEFT", self);
                self:SetWidth(portrait:GetWidth());
            end
        end
    end
end

function Threatrack:OnLoad()
    Threatrack = self;

    Threatrack_HandleDetection(function()
        self:Update();
    end);
end
