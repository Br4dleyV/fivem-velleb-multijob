---Function to get players current jobs from the database
---@param src number
---@return table|nil
function getJobsFromDb(identifier)
    local jobs = {} -- Empty table to hold jobs
    local result

    if Config.Framework == 'qb' then
        result = MySQL.query.await('SELECT job, grade FROM player_jobs WHERE citizenid = :citizenid', { citizenid = identifier })
    elseif Config.Framework == 'esx' then
        result = MySQL.query.await('SELECT job, grade FROM user_jobs WHERE identifier = :identifier', { identifier = identifier })
    end

    if result and #result > 0 then -- If there are results
        local frameworkJobs = Bridge.GetFrameworkJobs()
        if not frameworkJobs then return nil end
        for _, row in pairs(result) do -- Add job to jobs table
            local jobInfo = frameworkJobs[row.job]
            if jobInfo then
                table.insert(jobs, {
                    name = row.job,
                    label = jobInfo.label,
                    grade = row.grade
                })
            end
        end
    end
    return jobs
end

---Callback to get player's current data
Bridge.RegisterCallback('velleb-multijob:server:getPlayer', function(source, cb)
    local src = source

    -- Get player
    local Player = Bridge.GetPlayer(src)

    if Player then
        cb(Player.PlayerData) -- Return player data
    else
        cb(nil) -- Return nil if player not found
    end
end)

---Callback to get player's jobs for the multijob menu
Bridge.RegisterCallback('velleb-multijob:server:getPlayerJobs', function(source, cb)
    local src = source
    local Player = Bridge.GetPlayer(src) -- Get player 
    if not Player then cb(nil) return end

    local result = getJobsFromDb(src) -- Get jobs from database
    if not result then -- If no jobs found, return nil
        cb(nil)
        return
    end

    cb(result) -- Return jobs
end)

---Event to set player's job from the multijob menu
RegisterNetEvent('velleb-multijob:server:setPlayerJob', function(data)
    local src = source
    local Player = Bridge.GetPlayer(src) -- Get player
    if not Player then Bridge.Notify(src, 'Player not found.', 'error') return end
    local newJob = data.jobName -- Get new job name from data

    -- Validate if player has the job in their jobs list
    local jobs = getJobsFromDb(Player.PlayerData.citizenid) -- Get jobs from database
    for _, job in pairs(jobs) do
        if job.name == newJob then -- If player has the job
            local frameworkJobs = Bridge.GetFrameworkJobs()
            if not frameworkJobs then Bridge.Notify(src, 'Framework jobs not found.', 'error') return end
            if frameworkJobs[newJob] then -- Validate if job exists in shared jobs
                Player.Functions.SetJob(newJob, job.grade) -- Set player's job
                Player.Functions.SetJobDuty(frameworkJobs[newJob].defaultDuty) -- Set job duty based on defaultDuty
                Bridge.Notify(src, 'Your job has been changed to ' .. frameworkJobs[newJob].label .. '.', 'success') -- Notify player of job change
                return
            else
                Bridge.Notify(src, 'Please contact an administrator.', 'error') -- Notify player to contact admin if job doesn't exist
                return
            end
        end
    end

    Bridge.Notify(src, 'You do not have access to this job.', 'error') -- Notify player if they don't have access to the job
end)

---Listener for job updates to save to database
RegisterNetEvent('QBCore:Server:OnJobUpdate', function(source, JobInfo)
    local Player = Bridge.GetPlayer(source) -- Get player

    if Player then
        -- Save job to database
        if JobInfo then
            -- Check if job already exists in player_jobs. If already exists, update grade, else insert new record
            local result = MySQL.scalar.await('SELECT 1 FROM player_jobs WHERE citizenid = :citizenid AND job = :job',
                { citizenid = Player.PlayerData.citizenid, job = JobInfo.name })

            if result then
                -- Update existing job grade
                MySQL.update.await('UPDATE player_jobs SET grade = :grade WHERE citizenid = :citizenid AND job = :job',
                    { grade = JobInfo.grade.level, citizenid = Player.PlayerData.citizenid, job = JobInfo.name })
            else
                -- Insert new job record
                MySQL.insert.await('INSERT INTO player_jobs (citizenid, job, grade) VALUES (:citizenid, :job, :grade)',
                    { citizenid = Player.PlayerData.citizenid, job = JobInfo.name, grade = JobInfo.grade.level })
            end
        end
    end
end)
