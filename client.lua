-- client.lua
local QBCore = exports['qb-core']:GetCoreObject()
local isPerforming = false
local currentTrackUrl = ""
local miniGameActive = false
local miniGameScore = 0
local lastActionTime = GetGameTimer()
local instrument = "guitar"  -- Default instrument; can be chosen dynamically

-- Utility: Load an animation dictionary
function LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(10)
    end
end

-- Send UI messages to React-based NUI
function OpenUI(action, payload)
    payload.action = action
    SendNUIMessage(payload)
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

-- Initiate performance: set up UI, play audio, trigger animations/effects, start mini-game, and monitor dynamic stage presence
function StartPerformance(trackUrl)
    OpenUI("openPerformanceUI", { trackUrl = trackUrl })

    -- Play track via audio resource (server caching is handled on the server)
    exports['xsound']:PlayUrlSound('performance', trackUrl, 0.5)

    -- Play instrument animation
    local instrumentData = Config.Instruments[instrument]
    if instrumentData then
        LoadAnimDict(instrumentData.animDict)
        TaskPlayAnim(PlayerPedId(), instrumentData.animDict, instrumentData.animName, 8.0, -8.0, -1, 49, 0, false, false, false)
    end

    TriggerStageEffects()
    StartMiniGame()
    MonitorDynamicStage()
end

-- Monitor player activity for dynamic stage presence; update UI if idle too long
function MonitorDynamicStage()
    Citizen.CreateThread(function()
        while isPerforming do
            Citizen.Wait(1000)
            if GetGameTimer() - lastActionTime > Config.DynamicStage.idleTimeThreshold then
                QBCore.Functions.Notify("The crowd is losing interest!", "error")
                OpenUI("crowdReaction", { reaction = "boo" })
            end
        end
    end)
end

-- Trigger stage effects via server events
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

-- Mini-game: simple note-hitting simulation (Guitar Hero–style)
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
                    lastActionTime = GetGameTimer()
                    break
                end
                Citizen.Wait(0)
            end

            if hit then
                miniGameScore = miniGameScore + (Config.MiniGame.scorePerNote or 10)
                QBCore.Functions.Notify("Good hit! Score: " .. miniGameScore, "success")
                OpenUI("updateScore", { score = miniGameScore })
            else
                QBCore.Functions.Notify("Missed note!", "error")
            end
        end
        miniGameActive = false
        QBCore.Functions.Notify("Performance ended! Final Score: " .. miniGameScore, "success")
        EndPerformance()
    end)
end

-- End performance: cleanup UI, audio, animations and open rating UI
function EndPerformance()
    isPerforming = false
    SetNuiFocus(false, false)
    OpenUI("closePerformanceUI", {})
    exports['xsound']:StopSound('performance')
    ClearPedTasks(PlayerPedId())
    StopScreenEffect("HeistCelebPass")

    OpenUI("openRatingUI", { maxRating = Config.PerformanceScoreUI.ratingScale })
end

-- Donation notification from server
RegisterNetEvent('music:client:DonationReceived', function(amount)
    QBCore.Functions.Notify("You received a donation of $" .. amount, "success")
    OpenUI("donationNotification", { amount = amount })
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

-- UI callbacks from the React NUI
RegisterNUICallback('uiAction', function(data, cb)
    if data.action == "buyTicket" then
        TriggerServerEvent('music:server:BuyTicket', {})
    elseif data.action == "signContract" then
        TriggerServerEvent('music:server:SignRecordContract', {label = data.label, terms = data.terms})
    elseif data.action == "ratePerformance" then
        TriggerServerEvent('music:server:UpdatePerformanceRating', {rating = data.rating})
    elseif data.action == "djMix" then
        QBCore.Functions.Notify("DJ mixing initiated!", "primary")
    elseif data.action == "requestSong" then
        if data.songUrl and data.songUrl ~= "" then
            TriggerServerEvent('music:server:SongRequest', {songUrl = data.songUrl, requester = GetPlayerName(PlayerId())})
        else
            QBCore.Functions.Notify("Invalid song URL!", "error")
        end
    end
    cb('ok')
end)

-- Additional Commands

RegisterCommand("songrequest", function(source, args)
    local requestUrl = args[1] or ""
    if requestUrl == "" then
        QBCore.Functions.Notify("Please provide a song URL for the request.", "error")
        return
    end
    TriggerServerEvent('music:server:SongRequest', {songUrl = requestUrl, requester = GetPlayerName(PlayerId())})
end, false)

RegisterCommand("skipsong", function(source, args)
    TriggerServerEvent('music:server:SkipSong')
end, false)

RegisterCommand("rapbattle", function(source, args)
    if Config.EventFeatures.rapBattle then
        TriggerServerEvent('music:server:StartRapBattle', {initiator = GetPlayerName(PlayerId())})
    end
end, false)

RegisterCommand("talkshow", function(source, args)
    if Config.EventFeatures.liveTalkShow then
        TriggerServerEvent('music:server:StartTalkShow', {host = GetPlayerName(PlayerId())})
    end
end, false)

RegisterCommand("djmix", function(source, args)
    if Config.DJSystem.turntableUI then
        OpenUI("openDJUI", {})
    end
end, false)

RegisterCommand("vippass", function(source, args)
    if Config.VIPPass.enabled then
        QBCore.Functions.Notify("VIP backstage access granted!", "success")
        OpenUI("vipAccess", {})
    end
end, false)

RegisterCommand("festival", function(source, args)
    if Config.VirtualFestival.enabled then
        QBCore.Functions.Notify("Welcome to the Virtual Festival!", "success")
        OpenUI("festivalMode", {})
    end
end, false)

RegisterCommand("rankings", function(source, args)
    if Config.Competitive.liveArtistRankings then
        QBCore.Functions.Notify("Displaying live artist rankings!", "primary")
        OpenUI("showRankings", {})
    end
end, false)

RegisterCommand("musicawards", function(source, args)
    if Config.Competitive.musicAwards then
        QBCore.Functions.Notify("Music Awards initiated! Vote for Best Artist and Best Song.", "primary")
        OpenUI("musicAwards", {})
    end
end, false)

-- Listen for song request events from server
RegisterNetEvent('music:client:SongRequest', function(requestData)
    QBCore.Functions.Notify("Song request received: " .. requestData.songUrl, "primary")
    OpenUI("songRequestReceived", { songUrl = requestData.songUrl, requester = requestData.requester })
end)

-- Listen for song skip events from server
RegisterNetEvent('music:client:SkipSong', function()
    QBCore.Functions.Notify("Song skipped!", "error")
    exports['xsound']:StopSound('performance')
end)

-- Placeholder events for rap battle and talk show
RegisterNetEvent('music:client:StartRapBattle', function(battleData)
    QBCore.Functions.Notify("Rap battle started by: " .. battleData.initiator, "primary")
    OpenUI("startRapBattle", { initiator = battleData.initiator })
end)

RegisterNetEvent('music:client:StartTalkShow', function(showData)
    QBCore.Functions.Notify("Live Talk Show hosted by: " .. showData.host, "primary")
    OpenUI("startTalkShow", { host = showData.host })
end)
