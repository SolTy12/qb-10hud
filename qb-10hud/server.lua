--QB 10-System Tablet made by sol https://discord.gg/hRmZ3ERhEr0------
print('[qb-10hud] server.lua loaded successfully!')
local QBCore = exports['qb-core']:GetCoreObject()
local Cops = {}

-- =========================
-- CAVE ITEM HANDLING
-- =========================
RegisterNetEvent('qb-10hud:server:RemoveMokdan', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- Remove mokdan item from player inventory
    Player.Functions.RemoveItem(Config.Cave.RequiredItem, 1)
    TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[Config.Cave.RequiredItem], "remove")
end)

-- =========================
-- DATABASE FUNCTIONS
-- =========================
local function savePlayerTag(identifier, tag, color)
    -- קודם נבדוק אם השחקן קיים בטבלה
    MySQL.Async.fetchAll('SELECT citizenid FROM player_hud WHERE citizenid = @citizenid', {
        ['@citizenid'] = identifier
    }, function(result)
        if result and #result > 0 then
            -- עדכון שחקן קיים
            MySQL.Async.execute('UPDATE player_hud SET tag = @tag, color = @color WHERE citizenid = @citizenid', {
                ['@citizenid'] = identifier,
                ['@tag'] = tag,
                ['@color'] = color
            })
        else
            -- הוספת שחקן חדש
            MySQL.Async.execute('INSERT INTO player_hud (citizenid, tag, color) VALUES (@citizenid, @tag, @color)', {
                ['@citizenid'] = identifier,
                ['@tag'] = tag,
                ['@color'] = color
            })
        end
    end)
end

local function loadPlayerTag(identifier, callback)
    MySQL.Async.fetchAll('SELECT tag, color FROM player_hud WHERE citizenid = @citizenid', {
        ['@citizenid'] = identifier
    }, function(result)
        if result[1] then
            callback(result[1].tag, result[1].color)
        else
            callback(nil, nil)
        end
    end)
end

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
    print('[qb-10hud] Broadcasting list with ' .. #Cops .. ' officers')
    for src, data in pairs(Cops) do
        print('[qb-10hud] Officer: ' .. data.name .. ' (Tag: ' .. (data.tag or 'N/A') .. ')')
    end
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
    
    -- שמירת התג במסד הנתונים
    savePlayerTag(Player.PlayerData.citizenid, data.tag, data.color)

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
-- LOAD PLAYER TAG ON CONNECT
-- =========================
RegisterNetEvent('qb-10hud:loadPlayerTag', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    loadPlayerTag(Player.PlayerData.citizenid, function(tag, color)
        if tag and color then
            TriggerClientEvent('qb-10hud:setSavedTag', src, tag, color)
        end
    end)
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


-- כל הזכויות שמורות לסול