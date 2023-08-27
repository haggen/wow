-- Powerhythm
-- The MIT License © 2019 Arthur Corenzan

local POWERHYTHM = ...

UIParentLoadAddOn("Blizzard_DebugTools")

PowerhythmFrameMixin = {}

function PowerhythmFrameMixin:OnLoad()
	self.lastUpdateAt = GetTime()
	self.lastShotAt = 0
	self.swingDelta = 0
	self.lastSwingAt = 0
	self.shotDelta = 0

	self:RegisterForDrag("LeftButton");
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function PowerhythmFrameMixin:OnEvent(event, ...)
	if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		self:OnCombatLogEvent(CombatLogGetCurrentEventInfo())
	end
end

function PowerhythmFrameMixin:OnCombatLogEvent(...)
	local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags,
	sourceFlags2, targetGUID, targetName, targetFlags, targetFlags2 = ...

	if (sourceGUID ~= UnitGUID("player")) then
		return
	end

	if (subevent == "RANGE_DAMAGE") then
		local spellId, spellName, spellSchool, amount, overkill, school,
		resisted, blocked, absorbed, critical, glancing, crushing = select(12, ...)

		DevTools_Dump({ timestamp, sourceName, spellName, amount })

		if (self.lastShotAt > 0) then
			self.shotDelta = timestamp - self.lastShotAt
		end
		self.lastShotAt = timestamp
	end

	if (subevent == "SWING_DAMAGE") then
		local _, _, _, amount, overkill, school, resisted, blocked, absorbed,
		critical, glancing, crushing, spellName, spellSchool = select(12, ...)

		DevTools_Dump({ timestamp, sourceName, "Swing", amount })

		if (self.lastSwingAt > 0) then
			self.swingDelta = timestamp - self.lastSwingAt
		end
		self.lastSwingAt = timestamp
	end
end

function PowerhythmFrameMixin:OnUpdate()
	local now = GetTime()
	local elapsed = now - self.lastUpdateAt

	if (elapsed < 0.1) then
		return
	end

	self.lastUpdateAt = now
end
