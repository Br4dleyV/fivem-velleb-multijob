Bridge = {}

function Bridge.CreateTargetEntity(...)
    if Config.Target == "qb" then
        return exports['qb-target']:AddTargetEntity(...)
    elseif Config.Target == "ox" then
        return exports.ox_target:addEntity(...)
    else
        print("No target system detected. Cannot create target entity.")
        return nil
    end
end