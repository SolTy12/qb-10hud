local QBCore = exports['qb-core']:GetCoreObject()
local Cops = {}

-- =========================
-- CLEAN INVALID COPS
-- =========================
local function cleanCops()
    for src, _ in pairs(Cops) do
        if not QBCore.Functions.GetPlayer(tonumber(src)) then
            Cops[src] = nil
        end
    end
end

-- =========================
-- BROADCAST (SINGLE SOURCE)
-- =========================
local function broadcast()
    cleanCops()
    TriggerClientEvent('qb-10hud:update', -1, Cops)
end

-- =========================
-- ADD TO LIST
-- =========================
RegisterNetEvent('qb-10hud:onList', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if not Config.Jobs[Player.PlayerData.job.name] then return end

    local grade = Player.PlayerData.job.grade.level
    local departmentName = Config.DepartmentsByGrade[grade] or 'משטרה'

    Cops[src] = {
        name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        tag = data.tag,
        color = data.color,
        headshot = data.headshot,
        radio = '-',
        talking = false,
        grade = grade,
        department = departmentName
    }

    broadcast()
end)

-- =========================
-- REMOVE FROM LIST
-- =========================
RegisterNetEvent('qb-10hud:offList', function()
    Cops[source] = nil
    broadcast()
end)

-- =========================
-- RADIO CHANNEL UPDATE
-- =========================
RegisterNetEvent('qb-10hud:setRadio', function(channel)
    local src = source
    if not Cops[src] then return end

    Cops[src].radio = channel or '-'
    broadcast()
end)

-- =========================
-- RADIO TALKING
-- =========================
RegisterNetEvent('qb-10hud:setTalking', function(state)
    local src = source
    if not Cops[src] then return end

    if Cops[src].talking ~= state then
        Cops[src].talking = state
        broadcast()
    end
end)

-- =========================
-- SYNC FOR NEW PLAYER
-- =========================
RegisterNetEvent('qb-10hud:requestSync', function()
    cleanCops()
    TriggerClientEvent('qb-10hud:update', source, Cops)
end)

-- =========================
-- PLAYER DROPPED
-- =========================
AddEventHandler('playerDropped', function()
    Cops[source] = nil
    broadcast()
end)

-- =========================
-- JOB UPDATE
-- =========================
RegisterNetEvent('QBCore:Server:OnJobUpdate', function(job)
    local src = source

    if not Config.Jobs[job.name] then
        Cops[src] = nil
    else
        if Cops[src] then
            Cops[src].grade = job.grade.level
            Cops[src].department = Config.DepartmentsByGrade[job.grade.level] or 'משטרה'
        end
    end

    broadcast()
end)


---כל הזכויות שמורות לסול