-- Developer 1.0.0
-- The MIT License © 2018 Arthur Corenzan

_G = getfenv(0)

function d(...)
    local message = ""
    for i = 1, getn(arg) do
        message = message.." "..tostring(arg[i])
    end

    DeveloperMessageFrame:Show()
    DeveloperMessageFrame:AddMessage(message, 1, 1, 1)
end

function df(message, ...)
    DeveloperMessageFrame:Show()
    DeveloperMessageFrame:AddMessage(format(message, unpack(arg)), 1, 1, 1)
end

function dt(t, linePrefix, tableHistory)
    if not tableHistory then
        tableHistory = {}
    end

    linePrefix = linePrefix or ""

    if tableHistory[t] then
        df("%s...", linePrefix)
        return
    end

    for k, v in pairs(t) do
        if type(v) == "userdata" then
            v = getmetatable(v)
        end

        if type(v) == "table" then
            table.insert(tableHistory, v)
            df("%s[%s] = (table)", linePrefix, tostring(k))
            dt(v, linePrefix .. "    ", tableHistory)
        else
            df("%s[%s] = (%s) %s", linePrefix, tostring(k), type(v), tostring(v))
        end
    end
end

function string.split(s, separator)
    local splittedParts = {}
    local nextPosition, lastPosition = nil, 0

    while lastPosition do
        nextPosition = string.find(s, separator, lastPosition+1)
        table.insert(splittedParts, string.sub(s, lastPosition+1, (nextPosition or 0)-1))
        lastPosition = nextPosition
    end

    return unpack(splittedParts)
end

SlashCmdList.DUMP = function(message)
    assert(loadstring(format("d(%s)", message)))()
end
SLASH_DUMP1 = "/d"

SlashCmdList.QUERY = function(message)
    local queryTerm, nameOfTableBeingQueried = string.split(message, "%s")

    if nameOfTableBeingQueried then
        tableBeingQueried = _G[nameOfTableBeingQueried]
    else
        nameOfTableBeingQueried = "_G"
        tableBeingQueried = _G
    end

    if type(tableBeingQueried) ~= "table" then
        tableBeingQueried = getmetatable(tableBeingQueried)
    end

    assert(tableBeingQueried, "invalid argument")

    d("")
    df("Querying '%s' in %s:", queryTerm, nameOfTableBeingQueried)

    local matchCount = 1

    for k, v in pairs(tableBeingQueried) do
        local isMatch = string.find(string.lower(tostring(k)), queryTerm) 
        if isMatch then
            df("[%s] = %s", tostring(k), tostring(v))

            if matchCount > 20 then
                d("...")
                break
            end

            matchCount = matchCount + 1
        end
    end
end
SLASH_QUERY1 = "/q"
