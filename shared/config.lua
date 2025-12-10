-- Configuration | Feel free to edit settings here
Config = {
    EnableBlips = true, -- Shows blips on the map for the NPCs
    Locations = { -- Locations where the job changer NPCs will spawn
        vector4(431.99, -985.73, 30.71, 41.46),
        vector4(-548.0, -190.9, 38.22, 177.3),
        vector4(300.63, -579.7, 43.26, 78.3),
        vector4(-445.1, 6022.64, 31.49, 316.5),
        vector4(1847.99, 3678.8, 34.27, 213.79)
    },
    Ped = 'a_m_m_business_01' -- Ped model for the job changer NPCs
}

--- ###############################
--- # DO NOT EDIT BELOW THIS LINE #
--- ###############################

---Function to check for dependencies | DO NOT EDIT
---@param data table
---@return string|nil
function dependencyCheck(data) 
    for resourcename, framework in pairs(data) do
        if GetResourceState(resourcename) == "started" then
            return framework
        end
    end
    return nil
end

-- Auto-detect framework
Config.Framework = dependencyCheck({
    ['qb-core'] = "qb",
    ['qbx-core'] = "qb",
    ['es_extended'] = "esx",
}) or "standalone"

-- Auto-detect target system | Need one of these resources installed for this script to work
Config.Target = dependencyCheck({
    ['qb-target'] = "qb",
    ['ox_target'] = "ox",
}) or "standalone"