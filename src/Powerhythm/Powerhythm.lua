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
	self.shotDelta = UnitRangedDamage("player")
	self.isInCombat = 0

	self:RegisterForDrag("LeftButton");
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
end

function PowerhythmFrameMixin:OnEvent(event, ...)
	if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		self:OnCombatLogEvent(CombatLogGetCurrentEventInfo())
	end

	if (event == "PLAYER_REGEN_DISABLED") then
		self.isInCombat = 1
	end

	if (event == "PLAYER_REGEN_ENABLED") then
		self.isInCombat = 0
		self.lastShotAt = 0
		self.lastSwingAt = 0
	end
end

function PowerhythmFrameMixin:OnCombatLogEvent(...)
	local _, subevent, _, sourceGUID, sourceName, sourceFlags,
	sourceFlags2, targetGUID, targetName, targetFlags, targetFlags2 = ...

	local now = GetTime()

	if (sourceGUID ~= UnitGUID("player")) then
		return
	end

	if (subevent == "RANGE_DAMAGE") then
		local spellId, spellName, spellSchool, amount, overkill, school,
		resisted, blocked, absorbed, critical, glancing, crushing = select(12, ...)

		-- DevTools_Dump({ timestamp, sourceName, spellName, amount })

		if (self.lastShotAt > 0) then
			self.shotDelta = now - self.lastShotAt
		end
		self.lastShotAt = now
	end

	if (subevent == "SWING_DAMAGE") then
		local _, _, _, amount, overkill, school, resisted, blocked, absorbed,
		critical, glancing, crushing, spellName, spellSchool = select(12, ...)

		-- DevTools_Dump({ now, sourceName, "Swing", amount })

		if (self.lastSwingAt > 0) then
			self.swingDelta = now - self.lastSwingAt
		end
		self.lastSwingAt = now
	end
end

function PowerhythmFrameMixin:OnUpdate()
	local now = GetTime()
	local elapsed = now - self.lastUpdateAt

	if (elapsed < 0.1) then
		return
	end

	if (self.isInCombat == 1) then
		self.StateText:SetText("In combat")
		self.SwingDeltaText:SetText(string.format("Swing delta: %.2f", self.swingDelta))
		self.ShotDeltaText:SetText(string.format("Shot delta: %.2f", self.shotDelta))
	else
		self.StateText:SetText("Out of combat")
	end

	self.lastUpdateAt = now
end
