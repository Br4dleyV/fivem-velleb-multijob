Bridge = {}

function Bridge.RegisterCallback(name, cb) 
    if Config.Framework == "qb" then
        local QBCore = exports['qb-core']:GetCoreObject()
        QBCore.Functions.CreateCallback(name, cb)
    else
        print("No framework detected. Cannot register callback: " .. name)
    end
end

function Bridge.GetPlayer(source)
    if Config.Framework == "qb" then
        local QBCore = exports['qb-core']:GetCoreObject()
        return QBCore.Functions.GetPlayer(source)
    else
        print("No framework detected. Cannot get player for source: " .. tostring(source))
        return nil
    end
end