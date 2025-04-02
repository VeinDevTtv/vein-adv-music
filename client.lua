-- client.lua
local QBCore = exports['qb-core']:GetCoreObject()
local isPerforming = false
local currentTrackUrl = ""
local miniGameActive = false
local miniGameScore = 0
local lastActionTime = GetGameTimer()
local instrument = "guitar"  -- Default instrument; can be dynamically chosen

-- Utility: Load an animation dictionary
function LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(10)
    end
end

-- Start performance command with track URL parameter
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
    lastActionTime = GetGameTimer()
    TriggerServerEvent('music:server:SavePerformance', {trackUrl = currentTrackUrl})
    StartPerformance(currentTrackUrl)
end, false)

-- Initiate performance: set UI, play audio, trigger animations/effects, start mini-game, and monitor dynamic stage presence
function StartPerformance(trackUrl)
    SetNuiFocus(true, true)
    SendNUIMessage({action = "openPerformanceUI", trackUrl = trackUrl})

    -- Play track using xsound (with caching handled on server)
    exports['xsound']:PlayUrlSound('performance', trackUrl, 0.5)

    -- Play instrument animation
    local instrumentData = Config.Instruments[instrument]
    if instrumentData then
        LoadAnimDict(instrumentData.animDict)
        TaskPlayAnim(PlayerPedId(), instrumentData.animDict, instrumentData.animName, 8.0, -8.0, -1, 49, 0, false, false, false)
    end

    -- Trigger stage effects
    TriggerStageEffects()

    -- Start mini-game (Guitar Hero–style)
    StartMiniGame()

    -- Monitor player activity for dynamic stage presence
    MonitorDynamicStage()
end

-- Monitor player actions; if idle too long, simulate crowd losing interest
function MonitorDynamicStage()
    Citizen.CreateThread(function()
        while isPerforming do
            Citizen.Wait(1000)
            if GetGameTimer() - lastActionTime > Config.DynamicStage.idleTimeThreshold then
                QBCore.Functions.Notify("The crowd is losing interest!", "error")
                -- Optionally lower performance score or trigger a crowd reaction here
            end
        end
    end)
end

-- Trigger stage effects by firing server events
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

-- Mini-game: simple note-hitting simulation
function StartMiniGame()
    miniGameActive = true
    miniGameScore = 0
    local totalNotes = Config.MiniGame and Config.MiniGame.totalNotes or 10

    Citizen.CreateThread(function()
        for note = 1, totalNotes do
            if not miniGameActive then break end

            Citizen.Wait(2000)
            QBCore.Functions.Notify("Hit the note! (Press [E])", "primary")
            local noteStart = GetGameTimer()
            local hit = false

            while (GetGameTimer() - noteStart) < (Config.MiniGame.noteTimingWindow or 1000) do
                if IsControlJustPressed(0, 38) then -- [E] key
                    hit = true
                    lastActionTime = GetGameTimer() -- update activity
                    break
                end
                Citizen.Wait(0)
            end

            if hit then
                miniGameScore = miniGameScore + (Config.MiniGame.scorePerNote or 10)
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

-- End performance: clean up UI, audio, animations and open performance rating UI
function EndPerformance()
    isPerforming = false
    SetNuiFocus(false, false)
    SendNUIMessage({action = "closePerformanceUI"})
    exports['xsound']:StopSound('performance')
    ClearPedTasks(PlayerPedId())
    StopScreenEffect("HeistCelebPass")

    -- Open UI for performance rating (scale 1-10)
    SendNUIMessage({action = "openRatingUI", maxRating = Config.PerformanceScoreUI.ratingScale})
end

-- Donation notification from server
RegisterNetEvent('music:client:DonationReceived', function(amount)
    QBCore.Functions.Notify("You received a donation of $" .. amount, "success")
end)

-- Stage Effects: Dynamic lighting using a screen effect
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

-- UI callbacks for ticket purchase, record contract signing, performance rating, DJ mixing, etc.
RegisterNUICallback('uiAction', function(data, cb)
    if data.action == "buyTicket" then
        TriggerServerEvent('music:server:BuyTicket', {})
    elseif data.action == "signContract" then
        TriggerServerEvent('music:server:SignRecordContract', {label = data.label, terms = data.terms})
    elseif data.action == "ratePerformance" then
        TriggerServerEvent('music:server:UpdatePerformanceRating', {rating = data.rating})
    elseif data.action == "djMix" then
        -- Handle DJ mixing events (placeholder implementation)
        QBCore.Functions.Notify("DJ mixing initiated!", "primary")
    end
    cb('ok')
end)

-- New Commands for Additional Features

-- Command for song requests
RegisterCommand("songrequest", function(source, args)
    local requestUrl = args[1] or ""
    if requestUrl == "" then
        QBCore.Functions.Notify("Please provide a song URL for the request.", "error")
        return
    end
    TriggerServerEvent('music:server:SongRequest', {songUrl = requestUrl, requester = GetPlayerName(PlayerId())})
end, false)

-- Command to skip current song (for DJs/performers)
RegisterCommand("skipsong", function(source, args)
    TriggerServerEvent('music:server:SkipSong')
end, false)

-- Command to start a rap battle (placeholder)
RegisterCommand("rapbattle", function(source, args)
    if Config.EventFeatures.rapBattle then
        TriggerServerEvent('music:server:StartRapBattle', {initiator = GetPlayerName(PlayerId())})
    end
end, false)

-- Command to start a live talk show (placeholder)
RegisterCommand("talkshow", function(source, args)
    if Config.EventFeatures.liveTalkShow then
        TriggerServerEvent('music:server:StartTalkShow', {host = GetPlayerName(PlayerId())})
    end
end, false)

-- Command for DJ mixing (opens DJ turntable UI if enabled)
RegisterCommand("djmix", function(source, args)
    if Config.DJSystem.turntableUI then
        SendNUIMessage({action = "openDJUI"})
    end
end, false)

-- Command for VIP pass usage (placeholder)
RegisterCommand("vippass", function(source, args)
    if Config.VIPPass.enabled then
        QBCore.Functions.Notify("VIP backstage access granted!", "success")
        -- Additional VIP backstage logic can be implemented here
    end
end, false)

-- Command for Virtual Festival Mode (placeholder)
RegisterCommand("festival", function(source, args)
    if Config.VirtualFestival.enabled then
        QBCore.Functions.Notify("Welcome to the Virtual Festival!", "success")
        -- Additional logic for managing multiple stage performances can be implemented here
    end
end, false)

-- Command to view live artist rankings (placeholder)
RegisterCommand("rankings", function(source, args)
    if Config.Competitive.liveArtistRankings then
        -- Fetch and display rankings from the database (placeholder implementation)
        QBCore.Functions.Notify("Displaying live artist rankings!", "primary")
    end
end, false)

-- Command to trigger Music Awards System (placeholder)
RegisterCommand("musicawards", function(source, args)
    if Config.Competitive.musicAwards then
        QBCore.Functions.Notify("Music Awards initiated! Vote for Best Artist and Best Song.", "primary")
        -- Additional logic for award voting and reward distribution can be implemented here
    end
end, false)

-- Listen for song request events from the server to update UI or performance state
RegisterNetEvent('music:client:SongRequest', function(requestData)
    QBCore.Functions.Notify("Song request received: " .. requestData.songUrl, "primary")
    -- Optionally update the performance playlist or UI here
end)

-- Listen for song skip event from the server
RegisterNetEvent('music:client:SkipSong', function()
    QBCore.Functions.Notify("Song skipped!", "error")
    exports['xsound']:StopSound('performance')
    -- Optionally start the next song in a playlist if available
end)

-- Placeholder events for rap battle and live talk show to trigger custom UIs/effects
RegisterNetEvent('music:client:StartRapBattle', function(battleData)
    QBCore.Functions.Notify("Rap battle started by: " .. battleData.initiator, "primary")
    -- Implement rap battle UI and crowd voting mechanics here
end)

RegisterNetEvent('music:client:StartTalkShow', function(showData)
    QBCore.Functions.Notify("Live Talk Show hosted by: " .. showData.host, "primary")
    -- Implement live talk show conversation UI here
end)
