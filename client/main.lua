CreateThread(function()
    -- Create NPCs at the configured locations
    local model = Config.Ped
    RequestModel(model)                            -- Request model
    while not HasModelLoaded(model) do Wait(0) end -- Wait for model to load
    for _, loc in pairs(Config.Locations) do       -- Loop through locations
        -- Spawn ped
        local ped = CreatePed(0, model, loc.x, loc.y, loc.z - 1.0, loc.w, false, false)
        FreezeEntityPosition(ped, true)            -- Freeze ped
        SetEntityInvincible(ped, true)             -- Make invincible
        SetBlockingOfNonTemporaryEvents(ped, true) -- Stops from fleeing gunshots

        -- Add blip if enabled
        if Config.EnableBlips then
            local blip = AddBlipForEntity(ped)
            SetBlipSprite(blip, 280) -- Briefcase icon
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, 5) -- Blue color
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Change Job")
            EndTextCommandSetBlipName(blip)
        end

        -- Add interaction target or zone
        if Config.UseTarget then
            Bridge.CreateTargetEntity(ped, {
                options = {
                    {
                        type = "client",
                        event = "velleb-multijob:client:openJobMenu",
                        icon = "fas fa-briefcase",
                        label = "Change Job",
                    }
                },
                distance = 2.5,
            })
        else
            Bridge.CreateZone(ped, {
                event = "velleb-multijob:client:openJobMenu",
                label = "Press [E] to Change Job",
                distance = 2.5
            })
        end
    end
end)

---Event to open job selection menu
RegisterNetEvent('velleb-multijob:client:openJobMenu', function()
    -- Get player data
    local PlayerData = Bridge.GetPlayerData()
    if not PlayerData then
        Bridge.Notify("Could not retrieve player data.", "error")
        return
    end

    -- Options for context menu
    local options = {}

    -- Get current job and add as disabled option
    local currentJob = PlayerData.job
    table.insert(options, {
        title = 'Current Job: ' .. currentJob.label,
        description = 'You are currently working as ' .. currentJob.label,
        disabled = true,
        icon = 'fas fa-user-tie'
    })

    -- Trigger Callback to get other jobs player has from server
    Bridge.TriggerCallback('velleb-multijob:server:getPlayerJobs', function(jobs)
        if jobs then                     -- If jobs were returned
            for _, job in pairs(jobs) do -- Add each job as an option to the multijob menu
                if job.name ~= currentJob.name then
                    table.insert(options, {
                        title = 'Switch to ' .. job.label,
                        description = 'Grade: ' .. job.grade,
                        serverEvent = 'velleb-multijob:server:setPlayerJob', -- Server event to change job
                        args = { jobName = job.name },
                        icon = 'fas fa-exchange-alt'
                    })
                end
            end
        end

        -- Register context menu with ox_lib
        exports.ox_lib:registerContext({
            id = 'player_job_menu',
            title = 'Select Your Job',
            options = options,
        })

        -- Show the context menu
        exports.ox_lib:showContext('player_job_menu')
    end)
end)
