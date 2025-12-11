-- Define table and id column names based on framework so we don't repeat if/else in every query
local tableName = Config.Framework == 'qb' and 'player_jobs' or 'user_jobs'
local idColumn = Config.Framework == 'qb' and 'citizenid' or 'identifier'

---Function to get players current jobs from the database
---@param identifier string
---@return table|nil
function getJobsFromDb(identifier)
    local jobs = {} -- Empty table to hold jobs
    local result = MySQL.query.await(string.format('SELECT job, grade FROM %s WHERE %s = :id', tableName, idColumn),
        { id = identifier })

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
    -- Get player
    local Player = Bridge.GetPlayer(source)
    if Player then
        if Config.Framework == "qb" then
            cb(Player.PlayerData) -- Return player data
        else
            cb(Player)
        end
    else
        cb(nil)
    end
end)

---Callback to get player's jobs for the multijob menu
Bridge.RegisterCallback('velleb-multijob:server:getPlayerJobs', function(source, cb)
    local Player = Bridge.GetPlayer(source) -- Get player
    if not Player then
        cb(nil)
        return
    end

    local identifier = Bridge.GetIdentifier(Player)
    if not identifier then cb(nil) return end
    local result = getJobsFromDb(identifier) -- Get jobs from database
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
    local identifier = Bridge.GetIdentifier(Player)
    if not identifier then cb(nil) return end

    -- Validate if player has the job in their jobs list
    local jobs = getJobsFromDb(identifier) -- Get jobs from database
    local jobFound = false
    local jobGrade = 0

    for _, job in pairs(jobs) do
        if job.name == newJob then -- If player has the job
            jobFound = true
            jobGrade = job.grade
            break
        end
    end

    if jobFound then
        local frameworkJobs = Bridge.GetFrameworkJobs()
        if not frameworkJobs then
            Bridge.Notify(src, 'Framework jobs not found.', 'error')
            return
        end
        if frameworkJobs[newJob] then -- Validate if job exists in shared jobs
            Bridge.SetJob(Player, newJob, jobGrade) -- Set player's job
            Bridge.SetDuty(Player, frameworkJobs[newJob].defaultDuty) -- Set job duty based on defaultDuty
            Bridge.Notify(src, 'Your job has been changed to ' .. frameworkJobs[newJob].label .. '.', 'success') -- Notify player of job change
        else
            Bridge.Notify(src, 'Please contact an administrator.', 'error') -- Notify player to contact admin if job doesn't exist
        end
    else
        Bridge.Notify(src, 'You do not have access to this job.', 'error') -- Notify player if they don't have access to the job
    end
end)

---Listener for job updates to save to database
Bridge.OnJobUpdate(function(source, Player, JobInfo)
    if Player and JobInfo then
        local identifier = Bridge.GetIdentifier(Player)
        if not identifier then cb(nil) return end

        -- Dynamic SQL Queries based on Framework variables defined at the top
        local selectQuery = string.format('SELECT 1 FROM %s WHERE %s = :id AND job = :job', tableName, idColumn)
        local updateQuery = string.format('UPDATE %s SET grade = :grade WHERE %s = :id AND job = :job', tableName,
            idColumn)
        local insertQuery = string.format('INSERT INTO %s (%s, job, grade) VALUES (:id, :job, :grade)', tableName,
            idColumn)

        -- Check if job exists in DB
        local result = MySQL.scalar.await(selectQuery, {
            id = identifier,
            job = JobInfo.name
        })

        if result then
            -- Update existing job grade
            MySQL.update.await(updateQuery, {
                grade = JobInfo.grade,
                id = identifier,
                job = JobInfo.name
            })
        else
            -- Insert new job record
            MySQL.insert.await(insertQuery, {
                id = identifier,
                job = JobInfo.name,
                grade = JobInfo.grade
            })
        end
    end
end)
