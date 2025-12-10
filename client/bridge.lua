Bridge = {}

function Bridge.CreateTargetEntity(...)
    if Config.Target == "qb" then
        return exports['qb-target']:AddTargetEntity(...)
    elseif Config.Target == "ox" then
        local args = { ... } -- Get all arguments
        local entity = args[1] -- First argument is the entity
        local params = args[2] -- Second argument is the params table
        local options = {} -- Prepare options table for ox_target

        -- Map QB options to OX format 
        for _, v in ipairs(params.options or {}) do
            options[#options + 1] = {
                label = v.label, -- Use label from QB
                icon = v.icon, -- Use icon from QB
                groups = v.job or v.gang, -- Support both job and gang restrictions
                distance = params.distance, -- Set interaction distance
                canInteract = v.canInteract, -- Support custom interaction checks
                onSelect = v.action and function(data) v.action(data.entity) end, -- Custom action support
                event = (v.type == "client" or not v.type) and v.event or nil, -- Default to client event
                serverEvent = v.type == "server" and v.event or nil, -- Options for server events
                command = v.type == "command" and v.event or nil, -- Options for commands
            }
        end
        -- Use addLocalEntity so we don't need NetIDs or networking logic
        return exports.ox_target:addLocalEntity(entity, options)
    else
        print("No target system detected. Cannot create target entity.")
        return nil
    end
end