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

---Function to create an interaction zone
---@param entity number The entity to attach the zone to.
---@param options table A table with zone options.
---@return table -- The zone object from ox_lib.
function Bridge.CreateZone(entity, options)
    -- Check if 'lib' is loaded (from @ox_lib/init.lua)
    if not lib or not lib.points then
        print("^1Error: ox_lib is not loaded. Add '@ox_lib/init.lua' to fxmanifest.lua^7")
        return
    end

    -- Create the point using the global 'lib' object
    local point = lib.points.new({
        coords = GetEntityCoords(entity),
        distance = options.distance or 2.5,
        onExit = function()
            -- Hide UI when leaving
            lib.hideTextUI()
        end,
        nearby = function()
            -- Show UI when near
            lib.showTextUI(options.label or 'Press [E] to interact')

            -- Check for interaction key (E)
            if IsControlJustReleased(0, 38) then
                if options.event then
                    TriggerEvent(options.event, entity)
                end
            end
        end
    })

    return point
end

---Function to trigger a server callback
---@param name string
---@param cb function
---@param ... any
function Bridge.TriggerCallback(name, cb, ...)
    if Config.Framework == "qb" then
        local QBCore = exports['qb-core']:GetCoreObject()
        QBCore.Functions.TriggerCallback(name, cb, ...)
    elseif Config.Framework == "esx" then
        local ESX = exports['es_extended']:getSharedObject()
        ESX.TriggerServerCallback(name, cb, ...)
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
    elseif Config.Framework == "esx" then
        local ESX = exports['es_extended']:getSharedObject()
        return ESX.GetPlayerData()
    else
        print("No framework detected. Cannot get player data.")
        return nil
    end
end