-- Developer
-- MIT License © 2019 Arthur Corenzan
-- More on https://github.com/haggen/wow

SlashCmdList["GLOBALS"] = function(message)
    local query = string.lower(message);
    local globals = {};
    local checkpoint = GetTime();
    local count = 0;

    for key, value in pairs(_G) do
        if (string.find(string.lower(tostring(key)), query, nil, false)) then
            globals[key] = tostring(value);
            count = count + 1;
        end
    end

    UIParentLoadAddOn("Blizzard_DebugTools");
    DevTools_Dump(globals);
    print(string.format("Found %d result(s) in %.3f sec.", count, GetTime() - checkpoint));
end;
SLASH_GLOBALS1 = "/globals";
