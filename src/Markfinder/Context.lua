-- Add-on name and context.
local MARKFINDER, ctx = ...;

-- Create a frame to listen for events.
ctx.frame = CreateFrame("Frame");

-- Event handlers.
local handlers = {};

-- Register an event handler.
function ctx.frame:OnEvent(self, event, func)
    if not handlers[event] then
        handlers[event] = {};
    end

    table.insert(handlers[event], func);
end

-- Forward events to their handlers.
ctx.frame:SetScript("OnEvent", function(self, event, ...)
    if handlers[event] then
        for _, func in ipairs(handlers[event]) do
            func(self, ...);
        end
    end
end);

-- Announce a message in chat.
function ctx.Announce(message)
    print(string.format("Markfinder: %s", message));
end

-- Queue of functions to run when out of combat.
local outOfCombatQueue = {};

-- Run the out of combat queue.
ctx.frame:RegisterEvent("PLAYER_REGEN_ENABLED");
ctx.frame:OnEvent("PLAYER_REGEN_ENABLED", function()
    for i = 1, #outOfCombatQueue do
        outOfCombatQueue[i]();
    end

    wipe(outOfCombatQueue);
end);

-- Ensure func is invoked either now or when out of combat.
function ctx.OutOfCombat(func)
    if InCombatLockdown() then
        table.insert(outOfCombatQueue, func);
    else
        func();
    end
end
