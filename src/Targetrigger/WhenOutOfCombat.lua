local queue = {}
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:SetScript("OnEvent", function()
    local batch = queue
    queue = {}
    for _, entry in ipairs(batch) do
        entry.func(table.unpack(entry.args))
    end
end)

function WhenOutOfCombat(func, ...)
    if InCombatLockdown() then
        table.insert(queue, { func = func, args = { ... } })
    else
        func(...)
    end
end
