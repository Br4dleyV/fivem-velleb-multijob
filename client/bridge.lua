Bridge = {}

---Function to create target entity for interaction
---@param ... any
---@return any
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

---Function to trigger a server callback
---@param name string
---@param cb function
---@param ... any
function Bridge.TriggerCallback(name, cb, ...)
    if Config.Framework == "qb" then
        local QBCore = exports['qb-core']:GetCoreObject()
        QBCore.Functions.TriggerCallback(name, cb, ...)
    else
        print("No framework detected. Cannot trigger callback: " .. name)
        return nil
    end
end

---Function to send notification to player
---@param message string
---@param type string
---@param length number
function Bridge.Notify(message, type, length)
    if Config.Framework == "qb" then
        local QBCore = exports['qb-core']:GetCoreObject()
        QBCore.Functions.Notify(message, type, length)
    else
        print("No notification system detected. Message: " .. message)
    end
end

---Function to get player data
---@return table|nil
function Bridge.GetPlayerData()
    if Config.Framework == "qb" then
        local QBCore = exports['qb-core']:GetCoreObject()
        local Player = QBCore.Functions.GetPlayerData()
        return Player
    else
        print("No framework detected. Cannot get player data.")
        return nil
    end
end