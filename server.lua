-- server.lua
local QBCore = exports['qb-core']:GetCoreObject()

-- Save performance data to the database
RegisterNetEvent('music:server:SavePerformance', function(performanceData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local artist = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
        local trackUrl = performanceData.trackUrl
        local performanceTime = os.time()
        
        exports.oxmysql:execute("INSERT INTO " .. Config.DB.ConcertsTable .. " (artist, track_url, performance_time) VALUES (?, ?, ?)", 
            {artist, trackUrl, performanceTime})
        
        TriggerClientEvent('QBCore:Notify', src, "Performance saved!", "success")
    end
end)

-- Handle donation events: donor sends money to an artist
RegisterNetEvent('music:server:SendDonation', function(donationData)
    local src = source
    local donor = QBCore.Functions.GetPlayer(src)
    if donor then
        local artistCitizenId = donationData.artistCitizenId -- The citizenid of the artist receiving the donation
        local amount = donationData.amount
        local donorName = donor.PlayerData.charinfo.firstname .. " " .. donor.PlayerData.charinfo.lastname
        
        exports.oxmysql:execute("INSERT INTO " .. Config.DB.DonationsTable .. " (artist_id, donor, amount, donation_time) VALUES (?, ?, ?, ?)", {
            artistCitizenId, donorName, amount, os.time()
        })
        
        -- Notify the artist (using their source id, assumed passed in donationData.artistSource)
        TriggerClientEvent('music:client:DonationReceived', donationData.artistSource, amount)
        TriggerClientEvent('QBCore:Notify', src, "Donation sent!", "success")
    end
end)

-- Handle record contract signing by an artist with a record label
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

-- Handle concert ticket purchase events
RegisterNetEvent('music:server:BuyTicket', function(ticketData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local price = Config.DefaultTicketPrice
        if Player.Functions.RemoveMoney("cash", price) then
            -- Optionally, add a ticket item to the player's inventory (integrate with ox_inventory)
            TriggerClientEvent('QBCore:Notify', src, "Ticket purchased!", "success")
        else
            TriggerClientEvent('QBCore:Notify', src, "Insufficient funds!", "error")
        end
    end
end)

-- Stage Effects events: these simply broadcast to all clients
RegisterNetEvent('music:server:TriggerLightingEffects', function()
    TriggerClientEvent('music:client:TriggerLightingEffects', -1)
end)

RegisterNetEvent('music:server:TriggerFogMachine', function()
    TriggerClientEvent('music:client:TriggerFogMachine', -1)
end)

RegisterNetEvent('music:server:TriggerFireworks', function()
    TriggerClientEvent('music:client:TriggerFireworks', -1)
end)
