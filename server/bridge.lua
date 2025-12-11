Bridge = {}

---Function to register a server callback
---@param name string
---@param cb function
function Bridge.RegisterCallback(name, cb)
    if Config.Framework == "qb" then
        local QBCore = exports['qb-core']:GetCoreObject()
        QBCore.Functions.CreateCallback(name, cb)
    elseif Config.Framework == "esx" then
        local ESX = exports['es_extended']:getSharedObject()
        ESX.RegisterServerCallback(name, cb)
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
    elseif Config.Framework == "esx" then
        local ESX = exports['es_extended']:getSharedObject()
        return ESX.GetPlayerFromId(source)
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
    elseif Config.Framework == "esx" then
        local ESX = exports['es_extended']:getSharedObject()
        return ESX.GetJobs()
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
    elseif Config.Framework == "esx" then
        TriggerClientEvent('esx:showNotification', src, message)
    else
        print("No notification system detected. Message: " .. message)
    end
end

---Function to get a players identifier (citizenid or identifier based on framework)
---@param Player table
---@return string|nil
function Bridge.GetIdentifier(Player)
    if Config.Framework == "qb" then
        return Player.PlayerData.citizenid
    elseif Config.Framework == "esx" then
        return Player.identifier
    end
end

---Function to set a players job
---@param Player table
---@param jobName string
---@param grade number
function Bridge.SetJob(Player, jobName, grade)
    if Config.Framework == "qb" then
        Player.Functions.SetJob(jobName, grade)
    elseif Config.Framework == "esx" then
        Player.setJob(jobName, grade)
    end
end

---Function to set a players duty status (if applicable)
---@param Player table
---@param state boolean
---@return void
function Bridge.SetDuty(Player, state)
    if Config.Framework == "qb" then
        Player.Functions.SetJobDuty(state)
    elseif Config.Framework == "esx" then
        -- ESX does not have a standard 'duty' function.
    end
end

---Function to listen for job updates
---@param cb function
---@return void
function Bridge.OnJobUpdate(cb)
    if Config.Framework == "qb" then
        RegisterNetEvent('QBCore:Server:OnJobUpdate', function(source, JobInfo)
            local QBCore = exports['qb-core']:GetCoreObject()
            local Player = QBCore.Functions.GetPlayer(source)
            if not Player then return end

            -- Normalize QBCore data to a standard format
            local data = {
                name = JobInfo.name,
                label = JobInfo.label,
                grade = JobInfo.grade.level -- QBCore uses nested grade.level
            }
            cb(source, Player, data)
        end)
    elseif Config.Framework == "esx" then
        RegisterNetEvent('esx:setJob', function(source, newJob, lastJob)
            local ESX = exports['es_extended']:getSharedObject()
            local xPlayer = ESX.GetPlayerFromId(source)
            if not xPlayer then return end

            -- Normalize ESX data to a standard format
            local data = {
                name = newJob.name,
                label = newJob.label,
                grade = newJob.grade -- ESX uses flat grade
            }
            cb(source, xPlayer, data)
        end)
    end
end
