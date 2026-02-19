--QB 10-System Tablet made by sol https://discord.gg/hRmZ3ERhEr0------

local QBCore = exports['qb-core']:GetCoreObject()
local hudEnabled = false
local lastRadio = nil
local caveOpenCooldown = false

-- =========================
-- INVENTORY DETECTION
-- =========================
local function GetInventorySystem()
    if GetResourceState('ox_inventory') == 'started' then
        return 'ox'
    elseif GetResourceState('qb-inventory') == 'started' then
        return 'qb'
    else
        return 'unknown'
    end
end

-- =========================
-- ITEM CHECK FUNCTIONS
-- =========================
local function HasMokdanItem(callback)
    local inventory = GetInventorySystem()
    
    if inventory == 'ox' then
        exports.ox_inventory:Search('count', Config.Cave.RequiredItem, function(count)
            callback(count and count > 0)
        end)
    elseif inventory == 'qb' then
        -- Try direct QBCore inventory check first
        local PlayerData = QBCore.Functions.GetPlayerData()
        if PlayerData and PlayerData.items then
            local hasItem = false
            for _, item in pairs(PlayerData.items) do
                if item.name == Config.Cave.RequiredItem then
                    hasItem = true
                    break
                end
            end
            callback(hasItem)
        else
            QBCore.Functions.TriggerCallback('QBCore:HasItem', function(hasItem)
                callback(hasItem)
            end, Config.Cave.RequiredItem)
        end
    else
        callback(false)
    end
end

-- =========================
-- CAVE SYSTEM
-- =========================
local function OpenCave()
    if caveOpenCooldown then
        TriggerEvent('QBCore:Notify', Config.Cave.NotificationMessages.cooldown, 'error')
        return
    end
    
    HasMokdanItem(function(hasItem)
        if hasItem then
            TriggerEvent('QBCore:Notify', Config.Cave.NotificationMessages.success, 'success')
            
            -- Add your cave opening logic here
            -- For example: teleport, open door, etc.
            
            caveOpenCooldown = true
            SetTimeout(Config.Cave.CooldownTime, function()
                caveOpenCooldown = false
            end)
        else
            TriggerEvent('QBCore:Notify', Config.Cave.NotificationMessages.error, 'error')
        end
    end)
end

-- Register key binding for cave opening
RegisterKeyMapping('opencave', 'Open Cave', 'keyboard', 'F10')
RegisterCommand('opencave', function()
    OpenCave()
end, false)

-- =========================
-- ITEM USE HANDLING
-- =========================
RegisterNetEvent('QBCore:Client:UseItem', function(item)
    if item.name == Config.Cave.RequiredItem then
        local PlayerData = QBCore.Functions.GetPlayerData()
        if not PlayerData.job or not Config.Jobs[PlayerData.job.name] then 
            TriggerEvent('QBCore:Notify', 'אין לך את הגישה המתאימה למערכת!', 'error')
            return 
        end
        
        SetNuiFocus(true, true)
        SendNUIMessage({ action = 'openSettings' })
    end
end)

-- Alternative event handlers for different inventory systems
RegisterNetEvent('ox_inventory:usedItem', function(itemName, slotId)
    if itemName == Config.Cave.RequiredItem then
        local PlayerData = QBCore.Functions.GetPlayerData()
        if not PlayerData.job or not Config.Jobs[PlayerData.job.name] then 
            TriggerEvent('QBCore:Notify', 'אין לך את הגישה המתאימה למערכת!', 'error')
            return 
        end
        
        SetNuiFocus(true, true)
        SendNUIMessage({ action = 'openSettings' })
    end
end)

-- =========================
-- SETTINGS MENU
-- =========================
RegisterCommand('10settings', function()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if not PlayerData.job or not Config.Jobs[PlayerData.job.name] then return end
    
    -- Check if mokdan item is required for UI
    if Config.Cave.RequireItemForUI then
        HasMokdanItem(function(hasItem)
            if hasItem then
                SetNuiFocus(true, true)
                SendNUIMessage({ action = 'openSettings' })
            else
                TriggerEvent('QBCore:Notify', Config.Cave.NotificationMessages.noitem, 'error')
            end
        end)
    else
        SetNuiFocus(true, true)
        SendNUIMessage({ action = 'openSettings' })
    end
end)

-- =========================
-- HEADSHOT (MugShotBase64)
-- =========================
local function getHeadshot()
    local ped = PlayerPedId()
    
    -- Try to get the image from MugShotBase64
    local success, result = pcall(function()
        if exports['MugShotBase64'] then
            local mugshot = exports['MugShotBase64']:GetMugShotBase64(ped)
            if mugshot and mugshot ~= "" then
                return mugshot
            end
            
            mugshot = exports['MugShotBase64']:GetMugShot(ped)
            if mugshot and mugshot ~= "" then
                return mugshot
            end
            
            mugshot = exports['MugShotBase64'].GetMugShotBase64(ped)
            if mugshot and mugshot ~= "" then
                return mugshot
            end
        end
        return nil
    end)
    
    if success and result and result ~= "" then
        return result
    end
    
    -- Fallback to the original system if MugShotBase64 is not available
    local handle = RegisterPedheadshot(ped)
    while not IsPedheadshotReady(handle) do Wait(10) end
    local txd = GetPedheadshotTxdString(handle)
    return txd
end

RegisterKeyMapping('10settings', '10-System Settings', 'keyboard', Config.OpenKey)

RegisterNUICallback('onList', function(data, cb)
    hudEnabled = true

    TriggerServerEvent('qb-10hud:onList', {
        tag = data.tag,
        color = data.color,
        headshot = getHeadshot()
    })

    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'toggleHud', state = true })
    SendNUIMessage({ action = 'closeSettings' })
    cb('ok')
end)

RegisterNUICallback('offList', function(_, cb)
    hudEnabled = false
    TriggerServerEvent('qb-10hud:offList')
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'toggleHud', state = false })
    SendNUIMessage({ action = 'closeSettings' })
    cb('ok')
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeSettings' })
    cb('ok')
end)

-- =========================
-- LIST UPDATE
-- =========================
RegisterNetEvent('qb-10hud:update', function(list)
    if not hudEnabled then return end
    SendNUIMessage({ action = 'update', list = list })
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    -- איפוס מקומי
    hudEnabled = false
    lastRadio = nil

    -- סגירת HUD בצד הלקוח
    SendNUIMessage({ action = 'toggleHud', state = false })

    -- בקשת סנכרון מהשרת
    TriggerServerEvent('qb-10hud:requestSync')
    
    -- טעינת התג השמור
    TriggerServerEvent('qb-10hud:loadPlayerTag')
end)

RegisterNetEvent('qb-10hud:setSavedTag', function(tag, color)
    SendNUIMessage({ 
        action = 'setSavedTag', 
        tag = tag, 
        color = color 
    })
end)

-- =====================================================
-- 🔑 RADIO TALKING (SOURCE OF TRUTH – PMA-VOICE)
-- =====================================================
AddEventHandler("pma-voice:radioActive", function(talking)
    if not hudEnabled then return end
    TriggerServerEvent("qb-10hud:setTalking", talking)
end)

-- =====================================================
-- RADIO CHANNEL SYNC (SEPARATE & STABLE)
-- =====================================================
CreateThread(function()
    while true do
        Wait(500)

        if not hudEnabled then goto continue end

        local radio = LocalPlayer.state.radioChannel or '-'

        if radio ~= lastRadio then
            lastRadio = radio
            TriggerServerEvent('qb-10hud:setRadio', radio)
        end

        ::continue::
    end
end)



-- כל הזכויות שמורות לסול