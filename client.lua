-- client.lua
local QBCore = exports['qb-core']:GetCoreObject()
local isPerforming = false
local currentTrackUrl = ""
local miniGameActive = false
local miniGameScore = 0
local instrument = "guitar"  -- Default instrument; can be extended for dynamic selection

-- Utility function: Load an animation dictionary
function LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(10)
    end
end

-- Command to start a live performance
RegisterCommand("startperformance", function(source, args)
    if isPerforming then
        QBCore.Functions.Notify("You're already performing!", "error")
        return
    end

    currentTrackUrl = args[1] or ""
    if currentTrackUrl == "" then
        QBCore.Functions.Notify("Please provide a track URL.", "error")
        return
    end

    isPerforming = true
    TriggerServerEvent('music:server:SavePerformance', {trackUrl = currentTrackUrl})
    StartPerformance(currentTrackUrl)
end, false)

-- Initiate performance: sets UI, plays audio, triggers animations & stage effects, and starts the mini-game
function StartPerformance(trackUrl)
    -- Set NUI focus and open performance UI
    SetNuiFocus(true, true)
    SendNUIMessage({action = "openPerformanceUI", trackUrl = trackUrl})

    -- Play the music track via an external audio streaming resource (e.g., xsound)
    exports['xsound']:PlayUrlSound('performance', trackUrl, 0.5)

    -- Play the instrument animation
    local instrumentData = Config.Instruments[instrument]
    if instrumentData then
        LoadAnimDict(instrumentData.animDict)
        TaskPlayAnim(PlayerPedId(), instrumentData.animDict, instrumentData.animName, 8.0, -8.0, -1, 49, 0, false, false, false)
    end

    -- Trigger stage effects (lighting, fog, fireworks)
    TriggerStageEffects()

    -- Start the Guitar Hero–style mini-game
    StartMiniGame()
end

-- Trigger stage effects by notifying the server, which then broadcasts to all clients
function TriggerStageEffects()
    if Config.StageEffects.dynamicLighting then
        TriggerServerEvent('music:server:TriggerLightingEffects')
    end
    if Config.StageEffects.fogMachine then
        TriggerServerEvent('music:server:TriggerFogMachine')
    end
    if Config.StageEffects.fireworks then
        TriggerServerEvent('music:server:TriggerFireworks')
    end
end

-- Mini-game logic: simple note-hitting simulation
function StartMiniGame()
    miniGameActive = true
    miniGameScore = 0
    local totalNotes = Config.MiniGame.totalNotes

    Citizen.CreateThread(function()
        for note = 1, totalNotes do
            if not miniGameActive then break end

            -- Wait 2 seconds between notes
            Citizen.Wait(2000)
            QBCore.Functions.Notify("Hit the note! (Press [E])", "primary")
            local noteStart = GetGameTimer()
            local hit = false

            -- Allow a window for the player to press the key
            while (GetGameTimer() - noteStart) < Config.MiniGame.noteTimingWindow do
                if IsControlJustPressed(0, 38) then  -- [E] key
                    hit = true
                    break
                end
                Citizen.Wait(0)
            end

            if hit then
                miniGameScore = miniGameScore + Config.MiniGame.scorePerNote
                QBCore.Functions.Notify("Good hit! Score: " .. miniGameScore, "success")
            else
                QBCore.Functions.Notify("Missed note!", "error")
            end
        end
        miniGameActive = false
        QBCore.Functions.Notify("Performance ended! Final Score: " .. miniGameScore, "success")
        EndPerformance()
    end)
end

-- Clean up after performance ends: remove UI, stop audio, clear animations, and stop effects
function EndPerformance()
    isPerforming = false
    SetNuiFocus(false, false)
    SendNUIMessage({action = "closePerformanceUI"})
    exports['xsound']:StopSound('performance')
    ClearPedTasks(PlayerPedId())
    StopScreenEffect("HeistCelebPass")
end

-- Donation notification from the server
RegisterNetEvent('music:client:DonationReceived', function(amount)
    QBCore.Functions.Notify("You received a donation of $" .. amount, "success")
end)

-- Stage Effects: Dynamic Lighting using a screen effect
RegisterNetEvent('music:client:TriggerLightingEffects', function()
    StartScreenEffect("HeistCelebPass", 0, false)
    Citizen.SetTimeout(5000, function() 
        StopScreenEffect("HeistCelebPass") 
    end)
end)

-- Stage Effects: Fog Machine using particle effects
RegisterNetEvent('music:client:TriggerFogMachine', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    RequestNamedPtfxAsset("core")
    while not HasNamedPtfxAssetLoaded("core") do
        Citizen.Wait(10)
    end
    UseParticleFxAssetNextCall("core")
    local fx = StartParticleFxLoopedAtCoord("exp_grd_flare", pos.x, pos.y, pos.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
    Citizen.SetTimeout(5000, function() 
        StopParticleFxLooped(fx, 0) 
    end)
end)

-- Stage Effects: Fireworks using non-looped particle effects
RegisterNetEvent('music:client:TriggerFireworks', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    RequestNamedPtfxAsset("scr_indep_fireworks")
    while not HasNamedPtfxAssetLoaded("scr_indep_fireworks") do
        Citizen.Wait(10)
    end
    UseParticleFxAssetNextCall("scr_indep_fireworks")
    StartParticleFxNonLoopedAtCoord("scr_indep_firework_trailburst", pos.x, pos.y, pos.z + 10.0, 0.0, 0.0, 0.0, 1.0, false, false, false)
end)

-- Handle UI callbacks for actions like ticket purchase and contract signing
RegisterNUICallback('uiAction', function(data, cb)
    if data.action == "buyTicket" then
        TriggerServerEvent('music:server:BuyTicket', {})
    elseif data.action == "signContract" then
        TriggerServerEvent('music:server:SignRecordContract', {label = data.label, terms = data.terms})
    end
    cb('ok')
end)
