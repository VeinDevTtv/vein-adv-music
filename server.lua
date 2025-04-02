-- server.lua
local QBCore = exports['qb-core']:GetCoreObject()

-- Server–side audio caching (simple example)
local AudioCache = {}

RegisterNetEvent('music:server:SavePerformance', function(performanceData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local artist = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
        local trackUrl = performanceData.trackUrl
        local performanceTime = os.time()
        
        exports.oxmysql:execute("INSERT INTO " .. Config.DB.ConcertsTable .. " (artist, track_url, performance_time) VALUES (?, ?, ?)", 
            {artist, trackUrl, performanceTime})
        
        if Config.AudioCaching.enabled and not AudioCache[trackUrl] then
            AudioCache[trackUrl] = { cachedAt = os.time(), url = trackUrl }
        end
        
        TriggerClientEvent('QBCore:Notify', src, "Performance saved!", "success")
    end
end)

RegisterNetEvent('music:server:SendDonation', function(donationData)
    local src = source
    local donor = QBCore.Functions.GetPlayer(src)
    if donor then
        local artistCitizenId = donationData.artistCitizenId
        local amount = donationData.amount
        local donorName = donor.PlayerData.charinfo.firstname .. " " .. donor.PlayerData.charinfo.lastname
        
        exports.oxmysql:execute("INSERT INTO " .. Config.DB.DonationsTable .. " (artist_id, donor, amount, donation_time) VALUES (?, ?, ?, ?)", {
            artistCitizenId, donorName, amount, os.time()
        })
        
        TriggerClientEvent('music:client:DonationReceived', donationData.artistSource, amount)
        TriggerClientEvent('QBCore:Notify', src, "Donation sent!", "success")
    end
end)

RegisterNetEvent('music:server:SignRecordContract', function(contractData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local citizenid = Player.PlayerData.citizenid
        local label = contractData.label
        local contractTerms = contractData.terms
        
        exports.oxmysql:execute("UPDATE " .. Config.DB.ArtistsTable .. " SET record_label = ?, contract_terms = ? WHERE citizenid = ?", 
            {label, contractTerms, citizenid})
        
        TriggerClientEvent('QBCore:Notify', src, "Contract signed with " .. label, "success")
    end
end)

RegisterNetEvent('music:server:BuyTicket', function(ticketData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local price = Config.DefaultTicketPrice
        if Player.Functions.RemoveMoney("cash", price) then
            TriggerClientEvent('QBCore:Notify', src, "Ticket purchased!", "success")
        else
            TriggerClientEvent('QBCore:Notify', src, "Insufficient funds!", "error")
        end
    end
end)

RegisterNetEvent('music:server:SongRequest', function(requestData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        TriggerClientEvent('music:client:SongRequest', -1, requestData)
        TriggerClientEvent('QBCore:Notify', src, "Song request sent!", "success")
    end
end)

RegisterNetEvent('music:server:SkipSong', function()
    TriggerClientEvent('music:client:SkipSong', -1)
end)

RegisterNetEvent('music:server:StartRapBattle', function(battleData)
    local src = source
    TriggerClientEvent('music:client:StartRapBattle', -1, battleData)
end)

RegisterNetEvent('music:server:StartTalkShow', function(showData)
    local src = source
    TriggerClientEvent('music:client:StartTalkShow', -1, showData)
end)

RegisterNetEvent('music:server:UpdatePerformanceRating', function(ratingData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local citizenid = Player.PlayerData.citizenid
        local rating = tonumber(ratingData.rating)
        if rating and rating >= 1 and rating <= Config.PerformanceScoreUI.ratingScale then
            exports.oxmysql:execute("INSERT INTO " .. Config.DB.PerformanceRatings .. " (citizenid, rating, timestamp) VALUES (?, ?, ?)", 
                {citizenid, rating, os.time()})
            TriggerClientEvent('QBCore:Notify', src, "Performance rated: " .. rating, "success")
        else
            TriggerClientEvent('QBCore:Notify', src, "Invalid rating!", "error")
        end
    end
end)

RegisterNetEvent('music:server:TriggerLightingEffects', function()
    TriggerClientEvent('music:client:TriggerLightingEffects', -1)
end)

RegisterNetEvent('music:server:TriggerFogMachine', function()
    TriggerClientEvent('music:client:TriggerFogMachine', -1)
end)

RegisterNetEvent('music:server:TriggerFireworks', function()
    TriggerClientEvent('music:client:TriggerFireworks', -1)
end)
