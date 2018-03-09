-- Reposition 1.0.0
-- The MIT License © 2017 Arthur Corenzan

local function d(text)
    DEFAULT_CHAT_FRAME:AddMessage(text, 1, 1, 1)
end

local function df(text, ...)
    DEFAULT_CHAT_FRAME:AddMessage(format(text, unpack(arg)), 1, 1, 1)
end

--
--
--

local function RepositionPlayerFrame()
    PlayerFrame:ClearAllPoints()
    PlayerFrame:SetPoint("RIGHT", UIParent, "CENTER", -100, -200)
end

local function RepositionTargetFrame()
    TargetFrame:ClearAllPoints()
    TargetFrame:SetPoint("LEFT", UIParent, "CENTER", 100, -200)
end

RepositionPlayerFrame()
RepositionTargetFrame()

local castingBarFrameWasRepositioned

local function RepositionCastingBar()
    CastingBarFrame:ClearAllPoints()
    CastingBarFrame:SetPoint("BOTTOM", CastingBarFrame:GetParent(), "BOTTOM", 0, 200)
    castingBarFrameWasRepositioned = true
end

local CastingBarFrameOnShow = CastingBarFrame:GetScript("OnShow")
CastingBarFrame:SetScript("OnShow", function(self)
    if CastingBarFrameOnShow then 
        CastingBarFrameOnShow(self)
    end
    castingBarFrameWasRepositioned = false
end)

local CastingBarFrameOnUpdate = CastingBarFrame:GetScript("OnUpdate")
CastingBarFrame:SetScript("OnUpdate", function(self)
    if CastingBarFrameOnUpdate then 
        CastingBarFrameOnUpdate(self)
    end
    if not castingBarFrameWasRepositioned then
        RepositionCastingBar()
    end
end)

