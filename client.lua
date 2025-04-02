-- client.lua
local QBCore = exports['qb-core']:GetCoreObject()
local isPerforming = false
local currentTrackUrl = ""
local miniGameActive = false
local miniGameScore = 0
local lastActionTime = GetGameTimer()
local instrument = "guitar"  -- Default instrument; can be chosen dynamically
local effectHandles = {} -- Track particle effect handles for cleanup

-- Utility: Load an animation dictionary with timeout to prevent hanging
function LoadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        local timeout = GetGameTimer() + 5000 -- 5 second timeout
        while not HasAnimDictLoaded(dict) and GetGameTimer() < timeout do
            Citizen.Wait(10)
        end
        
        if not HasAnimDictLoaded(dict) then
            QBCore.Functions.Notify("Failed to load animation. Please try again.", "error")
            return false
        end
    end
    return true
end

-- Properly handle focus for UI interactions
function SetUIFocus(hasFocus)
    SetNuiFocus(hasFocus, hasFocus)
    SetNuiFocusKeepInput(not hasFocus)
end

-- Send messages to the React UI via NUI with added error handling
function OpenUI(action, payload)
    if not payload then payload = {} end
    payload.action = action
    
    -- Handle UI state transitions
    if action == "openPerformanceUI" or action == "openDJUI" or action == "openRatingUI" then
        SetUIFocus(true)
    elseif action == "closePerformanceUI" then
        SetUIFocus(false)
    end
    
    SendNUIMessage(payload)
end

-- Clean up any active resources
function CleanupResources()
    -- Stop animations
    ClearPedTasks(PlayerPedId())
    
    -- Stop screen effects
    StopScreenEffect("HeistCelebPass")
    
    -- Clean up any particle effects
    for _, handle in pairs(effectHandles) do
        if handle then
            StopParticleFxLooped(handle, 0)
        end
    end
    effectHandles = {}
    
    -- Clean up audio
    if exports['xsound'] and exports['xsound'].soundExists('performance') then
        exports['xsound']:StopSound('performance')
    end
    
    -- Reset state
    isPerforming = false
    miniGameActive = false
    SetUIFocus(false)
end

-- Command: /startperformance [track URL] [instrument type]
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
    
    -- Allow choosing instrument from command
    if args[2] and Config.Instruments[args[2]] then
        instrument = args[2]
    end

    isPerforming = true
    lastActionTime = GetGameTimer()
    TriggerServerEvent('music:server:SavePerformance', {trackUrl = currentTrackUrl, instrument = instrument})
    StartPerformance(currentTrackUrl)
end, false)

-- Command to stop performance
RegisterCommand("stopperformance", function(source, args)
    if not isPerforming then
        QBCore.Functions.Notify("You're not currently performing.", "error")
        return
    end
    
    EndPerformance()
    QBCore.Functions.Notify("Performance ended.", "success")
end, false)

function StartPerformance(trackUrl)
    OpenUI("openPerformanceUI", { trackUrl = trackUrl })

    -- Play track using an audio streaming resource with volume control and error handling
    if exports['xsound'] then
        local volume = Config.DefaultVolume or 0.5
        exports['xsound']:PlayUrlSound('performance', trackUrl, volume, function(success)
            if not success then
                QBCore.Functions.Notify("Failed to play the track. Check the URL and try again.", "error")
                EndPerformance()
            end
        end)
    else
        QBCore.Functions.Notify("xsound resource not found. Audio won't play.", "error")
    end

    -- Play instrument animation
    local instrumentData = Config.Instruments[instrument]
    if instrumentData then
        if LoadAnimDict(instrumentData.animDict) then
            TaskPlayAnim(PlayerPedId(), instrumentData.animDict, instrumentData.animName, 8.0, -8.0, -1, 49, 0, false, false, false)
        end
    end

    TriggerStageEffects()
    StartMiniGame()
    MonitorDynamicStage()
end

function MonitorDynamicStage()
    Citizen.CreateThread(function()
        while isPerforming do
            Citizen.Wait(1000)
            if GetGameTimer() - lastActionTime > Config.DynamicStage.idleTimeThreshold then
                QBCore.Functions.Notify("The crowd is losing interest!", "error")
                OpenUI("crowdReaction", { reaction = "boo" })
                -- Give the player a chance to recover before ending
                if GetGameTimer() - lastActionTime > Config.DynamicStage.idleTimeThreshold * 2 then
                    QBCore.Functions.Notify("The crowd has lost interest. Performance ended.", "error")
                    EndPerformance()
                    break
                end
            end
        end
    end)
end

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

function StartMiniGame()
    miniGameActive = true
    miniGameScore = 0
    local totalNotes = Config.MiniGame and Config.MiniGame.totalNotes or 10
    local noteTimingWindow = Config.MiniGame and Config.MiniGame.noteTimingWindow or 1000
    local scorePerNote = Config.MiniGame and Config.MiniGame.scorePerNote or 10

    Citizen.CreateThread(function()
        for note = 1, totalNotes do
            if not miniGameActive or not isPerforming then break end

            -- Dynamic difficulty - speed up as the game progresses
            local waitTime = 2000 - (note * 50)
            if waitTime < 800 then waitTime = 800 end
            
            Citizen.Wait(waitTime)
            QBCore.Functions.Notify("Hit the note! (Press [E])", "primary")
            local noteStart = GetGameTimer()
            local hit = false

            while (GetGameTimer() - noteStart) < noteTimingWindow do
                if not isPerforming then 
                    break 
                end
                
                if IsControlJustPressed(0, 38) then
                    hit = true
                    lastActionTime = GetGameTimer()
                    break
                end
                Citizen.Wait(0)
            end

            if hit then
                -- Calculate score based on timing - perfect hits get bonus points
                local timeElapsed = GetGameTimer() - noteStart
                local timingMultiplier = 1.0
                
                if timeElapsed < (noteTimingWindow * 0.3) then
                    timingMultiplier = 1.5
                    QBCore.Functions.Notify("Perfect Hit!", "success")
                end
                
                miniGameScore = miniGameScore + (scorePerNote * timingMultiplier)
                QBCore.Functions.Notify("Score: " .. miniGameScore, "success")
                OpenUI("updateScore", { score = miniGameScore })
            else
                QBCore.Functions.Notify("Missed note!", "error")
            end
        end
        
        if isPerforming then
            QBCore.Functions.Notify("Performance complete! Final Score: " .. miniGameScore, "success")
            TriggerServerEvent('music:server:SavePerformanceScore', {score = miniGameScore})
            OpenUI("openRatingUI", { maxRating = Config.PerformanceScoreUI.ratingScale })
        end
        miniGameActive = false
    end)
end

function EndPerformance()
    CleanupResources()
    TriggerServerEvent('music:server:EndPerformance')
    QBCore.Functions.Notify("Performance ended!", "primary")
end

RegisterNetEvent('music:client:DonationReceived', function(amount)
    QBCore.Functions.Notify("You received a donation of $" .. amount, "success")
    OpenUI("donationNotification", { amount = amount })
    -- Boost crowd reaction
    lastActionTime = GetGameTimer()
end)

RegisterNetEvent('music:client:TriggerLightingEffects', function()
    StartScreenEffect("HeistCelebPass", 0, false)
    Citizen.SetTimeout(5000, function() 
        StopScreenEffect("HeistCelebPass") 
    end)
end)

RegisterNetEvent('music:client:TriggerFogMachine', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    
    if not HasNamedPtfxAssetLoaded("core") then
        RequestNamedPtfxAsset("core")
        local timeout = GetGameTimer() + 5000
        while not HasNamedPtfxAssetLoaded("core") and GetGameTimer() < timeout do
            Citizen.Wait(10)
        end
    end
    
    if HasNamedPtfxAssetLoaded("core") then
        UseParticleFxAssetNextCall("core")
        local fx = StartParticleFxLoopedAtCoord("exp_grd_flare", pos.x, pos.y, pos.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
        table.insert(effectHandles, fx)
        Citizen.SetTimeout(5000, function() 
            if fx then
                StopParticleFxLooped(fx, 0)
                for i, handle in ipairs(effectHandles) do
                    if handle == fx then
                        table.remove(effectHandles, i)
                        break
                    end
                end
            end
        end)
    end
end)

RegisterNetEvent('music:client:TriggerFireworks', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    
    if not HasNamedPtfxAssetLoaded("scr_indep_fireworks") then
        RequestNamedPtfxAsset("scr_indep_fireworks")
        local timeout = GetGameTimer() + 5000
        while not HasNamedPtfxAssetLoaded("scr_indep_fireworks") and GetGameTimer() < timeout do
            Citizen.Wait(10)
        end
    end
    
    if HasNamedPtfxAssetLoaded("scr_indep_fireworks") then
        UseParticleFxAssetNextCall("scr_indep_fireworks")
        StartParticleFxNonLoopedAtCoord("scr_indep_firework_trailburst", pos.x, pos.y, pos.z + 10.0, 0.0, 0.0, 0.0, 1.0, false, false, false)
    end
end)

RegisterNUICallback('uiAction', function(data, cb)
    if not data or not data.action then
        cb('error')
        return
    end
    
    if data.action == "buyTicket" then
        TriggerServerEvent('music:server:BuyTicket', {})
    elseif data.action == "signContract" then
        TriggerServerEvent('music:server:SignRecordContract', {label = data.label, terms = data.terms})
    elseif data.action == "ratePerformance" then
        TriggerServerEvent('music:server:UpdatePerformanceRating', {rating = data.rating})
        SetUIFocus(false)
    elseif data.action == "djMix" then
        QBCore.Functions.Notify("DJ mixing initiated!", "primary")
    elseif data.action == "requestSong" then
        if data.songUrl and data.songUrl ~= "" then
            TriggerServerEvent('music:server:SongRequest', {songUrl = data.songUrl, requester = GetPlayerName(PlayerId())})
        else
            QBCore.Functions.Notify("Invalid song URL!", "error")
        end
    elseif data.action == "closeUI" then
        SetUIFocus(false)
    end
    
    cb('ok')
end)

-- Resource cleanup on player drop or resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName and isPerforming then
        CleanupResources()
    end
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

RegisterNetEvent('music:client:SongRequest', function(requestData)
    QBCore.Functions.Notify("Song request received: " .. requestData.songUrl, "primary")
end)

-- Help command
RegisterCommand("performancehelp", function(source, args)
    QBCore.Functions.Notify("Available commands: /startperformance, /stopperformance, /songrequest, /djmix, /rapbattle, /talkshow, /festival, /vippass, /rankings, /musicawards", "primary")
end, false)
