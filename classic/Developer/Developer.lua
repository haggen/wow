-- Developer
-- MIT License © 2019 Arthur Corenzan
-- More on https://github.com/haggen/wow

local function ParseQuery(message)
    local query = {
        patterns = {},
    };
    for term in string.gmatch(message, "%S+") do
        if (string.sub(term, 0, 5) == "type:") then
            query.type = string.sub(term, 6);
        else
            table.insert(query.patterns, term);
        end
    end
    return query;
end

local function MatchAll(subject, patterns)
    for i = 1, #patterns do
        if (not string.find(subject, patterns[i], nil, false)) then
            return false;
        end
    end
    return true;
end

SlashCmdList["GLOBALS"] = function(message)
    local query = ParseQuery(string.lower(message));
    local globals = {};
    local checkpoint = GetTime();
    local total = 0;

    for key, value in pairs(_G) do
        local name = string.lower(tostring(key));

        if (query.type == nil or query.type == type(value)) then
            if MatchAll(name, query.patterns) then
                globals[key] = tostring(value);
                total = total + 1;
            end
        end
    end

    UIParentLoadAddOn("Blizzard_DebugTools");
    DevTools_Dump(globals);
    print(string.format("Found %d result(s) in %.3f sec.", total, GetTime() - checkpoint));
end;
SLASH_GLOBALS1 = "/globals";
