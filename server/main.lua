local QBCore = exports['qb-core']:GetCoreObject()

---Function to get players current jobs from the database
---@param citizenid string
---@return table
function getJobsFromDb(citizenid)
    local jobs = {} -- Empty table to hold jobs
    local result = exports.oxmysql:fetchSync('SELECT job, grade FROM player_jobs WHERE citizenid = :citizenid', { citizenid = citizenid }) -- Fetch jobs from database
    if result then -- If there are results
        for _, row in pairs(result) do -- Add job to jobs table
            local jobInfo = QBCore.Shared.Jobs[row.job]
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

---Callback to get player's jobs for the multijob menu
QBCore.Functions.CreateCallback('velleb-multijob:server:getPlayerJobs', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src) -- Get player 

    local result = getJobsFromDb(Player.PlayerData.citizenid) -- Get jobs from database
    if not result then -- If no jobs found, return nil
        cb(nil)
        return
    end

    cb(result) -- Return jobs
end)

---Event to set player's job from the multijob menu
RegisterNetEvent('velleb-multijob:server:setPlayerJob', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src) -- Get player
    local newJob = data.jobName -- Get new job name from data

    -- Validate if player has the job in their jobs list
    local jobs = getJobsFromDb(Player.PlayerData.citizenid) -- Get jobs from database
    for _, job in pairs(jobs) do
        if job.name == newJob then -- If player has the job
            if QBCore.Shared.Jobs[newJob] then -- Validate if job exists in shared jobs
                Player.Functions.SetJob(newJob, job.grade) -- Set player's job
                Player.Functions.SetJobDuty(QBCore.Shared.Jobs[newJob].defaultDuty) -- Set job duty based on defaultDuty
                TriggerClientEvent('QBCore:Notify', src,
                    'Your job has been changed to ' .. QBCore.Shared.Jobs[newJob].label, 'success') -- Notify player of job change
                return
            else
                TriggerClientEvent('QBCore:Notify', src, 'Please contact an administrator.', 'error') -- Notify player to contact admin if job doesn't exist
                return
            end
        end
    end

    TriggerClientEvent('QBCore:Notify', src, 'You do not have access to this job.', 'error') -- Notify player if they don't have access to the job
end)

---Listener for job updates to save to database
RegisterNetEvent('QBCore:Server:OnJobUpdate', function(source, JobInfo)
    local Player = QBCore.Functions.GetPlayer(source) -- Get player

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

            TriggerClientEvent('QBCore:Notify', source, 'Your job has been updated to ' .. JobInfo.label, 'success') -- Notify player of job update
        end
    end
end)
