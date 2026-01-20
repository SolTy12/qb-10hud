local QBCore = exports['qb-core']:GetCoreObject()
local hudEnabled = false
local lastRadio = nil

-- =========================
-- HEADSHOT
-- =========================
local function getHeadshot()
    local ped = PlayerPedId()
    local handle = RegisterPedheadshot(ped)
    while not IsPedheadshotReady(handle) do Wait(10) end
    return GetPedheadshotTxdString(handle)
end

-- =========================
-- SETTINGS MENU
-- =========================
RegisterCommand('10settings', function()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if not PlayerData.job or not Config.Jobs[PlayerData.job.name] then return end
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'openSettings' })
end)

RegisterKeyMapping('10settings', '10-System Settings', 'keyboard', Config.OpenKey)

-- =========================
-- ON / OFF LIST
-- =========================
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



---כל הזכויות שמורות לסול