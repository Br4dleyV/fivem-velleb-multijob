Bridge = {}

---Function to register a server callback 
---@param name string
---@param cb function
function Bridge.RegisterCallback(name, cb)
    if Config.Framework == "qb" then
        local QBCore = exports['qb-core']:GetCoreObject()
        QBCore.Functions.CreateCallback(name, cb)
    else
        print("No framework detected. Cannot register callback: " .. name)
    end
end

---Function to get player object by source
---@param source number
---@return table|nil
function Bridge.GetPlayer(source)
    if Config.Framework == "qb" then
        local QBCore = exports['qb-core']:GetCoreObject()
        return QBCore.Functions.GetPlayer(source)
    else
        print("No framework detected. Cannot get player for source: " .. tostring(source))
        return nil
    end
end

---Function to get framework jobs
---@return table|nil
function Bridge.GetFrameworkJobs()
    if Config.Framework == "qb" then
        local QBCore = exports['qb-core']:GetCoreObject()
        return QBCore.Shared.Jobs
    else
        print("No framework detected. Cannot get framework jobs.")
        return nil
    end
end

---Function to send notification to player
---@param message string
---@param type string
---@param length number
function Bridge.Notify(src, message, type, length)
    if Config.Framework == "qb" then
        TriggerClientEvent('QBCore:Notify', src, message, type, length or 5000)
    else
        print("No notification system detected. Message: " .. message)
    end
end