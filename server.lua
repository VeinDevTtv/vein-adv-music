-- server.lua
local QBCore = exports['qb-core']:GetCoreObject()

-- Server-side audio caching with expiration
local AudioCache = {}

-- Initialize database tables if they don't exist
CreateThread(function()
    -- Check and create tables
    ensureDatabaseTables()
    
    -- Regular cleanup task for expired cached audio and old data
    if Config.AudioCaching and Config.AudioCaching.enabled then
        CreateThread(function()
            while true do
                purgeExpiredCache()
                Wait(60 * 60 * 1000) -- Run cleanup every hour
            end
        end)
    end
    
    if Config.Database and Config.Database.AutoCleanup then
        CreateThread(function()
            while true do
                performDatabaseCleanup()
                Wait(24 * 60 * 60 * 1000) -- Run cleanup every day
            end
        end)
    end
end)

-- Create database tables if they don't exist
function ensureDatabaseTables()
    if not exports.oxmysql then
        print("^1ERROR: oxmysql not found. Database functionality disabled.^7")
        return
    end
    
    -- Ensure tables exist
    exports.oxmysql:execute([[
        CREATE TABLE IF NOT EXISTS ]] .. Config.DB.ArtistsTable .. [[ (
            id INT(11) NOT NULL AUTO_INCREMENT,
            citizenid VARCHAR(50) NOT NULL,
            artist_name VARCHAR(100) NOT NULL,
            record_label VARCHAR(100) DEFAULT NULL,
            contract_terms TEXT DEFAULT NULL,
            total_performances INT(11) DEFAULT 0,
            total_earnings DECIMAL(10,2) DEFAULT 0.00,
            rating DECIMAL(3,2) DEFAULT 0.00,
            PRIMARY KEY (id),
            UNIQUE KEY citizenid (citizenid)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        
        CREATE TABLE IF NOT EXISTS ]] .. Config.DB.ConcertsTable .. [[ (
            id INT(11) NOT NULL AUTO_INCREMENT,
            artist_id INT(11) NOT NULL,
            track_url VARCHAR(255) NOT NULL,
            performance_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            duration INT(11) DEFAULT 0,
            score INT(11) DEFAULT 0,
            earnings DECIMAL(10,2) DEFAULT 0.00,
            PRIMARY KEY (id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        
        CREATE TABLE IF NOT EXISTS ]] .. Config.DB.DonationsTable .. [[ (
            id INT(11) NOT NULL AUTO_INCREMENT,
            artist_id INT(11) NOT NULL,
            donor_name VARCHAR(100) NOT NULL,
            amount DECIMAL(10,2) NOT NULL,
            donation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        
        CREATE TABLE IF NOT EXISTS ]] .. Config.DB.PerformanceRatings .. [[ (
            id INT(11) NOT NULL AUTO_INCREMENT,
            citizenid VARCHAR(50) NOT NULL,
            rating INT(2) NOT NULL,
            timestamp INT(11) NOT NULL,
            PRIMARY KEY (id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    
    print("^2Music performance database tables verified.^7")
end

-- Clean expired audio cache
function purgeExpiredCache()
    local now = os.time()
    local purged = 0
    
    for url, data in pairs(AudioCache) do
        if now - data.cachedAt > (Config.AudioCaching.cacheDuration or 3600) then
            AudioCache[url] = nil
            purged = purged + 1
        end
    end
    
    if purged > 0 then
        print("^3Purged " .. purged .. " expired audio cache entries.^7")
    end
end

-- Clean old database records
function performDatabaseCleanup()
    if not Config.Database or not Config.Database.AutoCleanup or not Config.Database.CleanupInterval then
        return
    end
    
    local cleanupDays = Config.Database.CleanupInterval
    local timestamp = os.time() - (cleanupDays * 24 * 60 * 60)
    
    if exports.oxmysql then
        -- Clean up old concert records
        exports.oxmysql:execute("DELETE FROM " .. Config.DB.ConcertsTable .. " WHERE UNIX_TIMESTAMP(performance_time) < ?", {timestamp}, 
            function(rowsAffected)
                if rowsAffected > 0 then
                    print("^3Cleaned up " .. rowsAffected .. " old concert records.^7")
                end
            end
        )
        
        -- Clean up old donation records
        exports.oxmysql:execute("DELETE FROM " .. Config.DB.DonationsTable .. " WHERE UNIX_TIMESTAMP(donation_time) < ?", {timestamp},
            function(rowsAffected)
                if rowsAffected > 0 then
                    print("^3Cleaned up " .. rowsAffected .. " old donation records.^7")
                end
            end
        )
    end
end

-- Save performance to database
RegisterNetEvent('music:server:SavePerformance', function(performanceData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local citizenid = Player.PlayerData.citizenid
    local artist = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
    local trackUrl = performanceData.trackUrl
    local instrument = performanceData.instrument or "guitar"
    local performanceTime = os.time()
    
    -- First ensure the artist exists in the database
    ensureArtistExists(citizenid, artist, function()
        -- Then save the performance
        if exports.oxmysql then
            exports.oxmysql:execute("SELECT id FROM " .. Config.DB.ArtistsTable .. " WHERE citizenid = ?", {citizenid}, 
                function(result)
                    if result and result[1] then
                        local artistId = result[1].id
                        
                        exports.oxmysql:execute("INSERT INTO " .. Config.DB.ConcertsTable .. " (artist_id, track_url, performance_time) VALUES (?, ?, FROM_UNIXTIME(?))", 
                            {artistId, trackUrl, performanceTime}, function(insertId)
                                if insertId then
                                    TriggerClientEvent('QBCore:Notify', src, "Performance saved!", "success")
                                end
                            end
                        )
                        
                        -- Update total performances count
                        exports.oxmysql:execute("UPDATE " .. Config.DB.ArtistsTable .. " SET total_performances = total_performances + 1 WHERE id = ?", {artistId})
                    end
                end
            )
        end
    end)
    
    -- Cache the audio if enabled
    if Config.AudioCaching and Config.AudioCaching.enabled and not AudioCache[trackUrl] then
        AudioCache[trackUrl] = { 
            cachedAt = os.time(), 
            url = trackUrl,
            instrument = instrument
        }
    end
end)

-- Save performance score
RegisterNetEvent('music:server:SavePerformanceScore', function(scoreData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local citizenid = Player.PlayerData.citizenid
    local score = tonumber(scoreData.score) or 0
    
    if exports.oxmysql then
        -- Get the most recent performance by this artist
        exports.oxmysql:execute("SELECT c.id FROM " .. Config.DB.ConcertsTable .. " c JOIN " .. Config.DB.ArtistsTable .. " a ON c.artist_id = a.id WHERE a.citizenid = ? ORDER BY c.performance_time DESC LIMIT 1",
            {citizenid}, function(result)
                if result and result[1] then
                    local concertId = result[1].id
                    
                    -- Update the score
                    exports.oxmysql:execute("UPDATE " .. Config.DB.ConcertsTable .. " SET score = ? WHERE id = ?", 
                        {score, concertId}
                    )
                end
            end
        )
    end
end)

-- End performance and update duration
RegisterNetEvent('music:server:EndPerformance', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local citizenid = Player.PlayerData.citizenid
    local duration = 0
    
    if exports.oxmysql then
        -- Get the most recent performance by this artist
        exports.oxmysql:execute("SELECT c.id, UNIX_TIMESTAMP(c.performance_time) as start_time FROM " .. Config.DB.ConcertsTable .. " c JOIN " .. Config.DB.ArtistsTable .. " a ON c.artist_id = a.id WHERE a.citizenid = ? ORDER BY c.performance_time DESC LIMIT 1",
            {citizenid}, function(result)
                if result and result[1] then
                    local concertId = result[1].id
                    local startTime = result[1].start_time
                    
                    -- Calculate duration in seconds
                    duration = os.time() - startTime
                    
                    -- Update the duration
                    exports.oxmysql:execute("UPDATE " .. Config.DB.ConcertsTable .. " SET duration = ? WHERE id = ?", 
                        {duration, concertId}
                    )
                end
            end
        )
    end
end)

-- Ensure artist exists in database
function ensureArtistExists(citizenid, artistName, callback)
    if not exports.oxmysql then 
        if callback then callback() end
        return 
    end
    
    exports.oxmysql:execute("SELECT id FROM " .. Config.DB.ArtistsTable .. " WHERE citizenid = ?", {citizenid}, 
        function(result)
            if not result or #result == 0 then
                -- Artist doesn't exist, create new record
                exports.oxmysql:execute("INSERT INTO " .. Config.DB.ArtistsTable .. " (citizenid, artist_name) VALUES (?, ?)", 
                    {citizenid, artistName}, function()
                        if callback then callback() end
                    end
                )
            else
                -- Artist exists
                if callback then callback() end
            end
        end
    )
end

-- Process donation
RegisterNetEvent('music:server:SendDonation', function(donationData)
    local src = source
    local donor = QBCore.Functions.GetPlayer(src)
    if not donor then return end
    
    local artistCitizenId = donationData.artistCitizenId
    local amount = tonumber(donationData.amount)
    
    -- Validate donation amount
    if not amount or amount < (Config.DonationMinAmount or 10) or amount > (Config.DonationMaxAmount or 1000) then
        TriggerClientEvent('QBCore:Notify', src, "Invalid donation amount!", "error")
        return
    end
    
    -- Ensure donor has enough money
    if donor.Functions.RemoveMoney("cash", amount) then
        local donorName = donor.PlayerData.charinfo.firstname .. " " .. donor.PlayerData.charinfo.lastname
        
        if exports.oxmysql then
            -- Get artist id
            exports.oxmysql:execute("SELECT id FROM " .. Config.DB.ArtistsTable .. " WHERE citizenid = ?", {artistCitizenId}, 
                function(result)
                    if result and result[1] then
                        local artistId = result[1].id
                        
                        -- Record the donation
                        exports.oxmysql:execute("INSERT INTO " .. Config.DB.DonationsTable .. " (artist_id, donor_name, amount, donation_time) VALUES (?, ?, ?, FROM_UNIXTIME(?))", 
                            {artistId, donorName, amount, os.time()}
                        )
                        
                        -- Update total earnings
                        exports.oxmysql:execute("UPDATE " .. Config.DB.ArtistsTable .. " SET total_earnings = total_earnings + ? WHERE id = ?", 
                            {amount, artistId}
                        )
                        
                        -- Find the artist's server ID to notify them
                        local targetPlayer = QBCore.Functions.GetPlayerByCitizenId(artistCitizenId)
                        if targetPlayer then
                            local targetSrc = targetPlayer.PlayerData.source
                            TriggerClientEvent('music:client:DonationReceived', targetSrc, amount)
                        end
                        
                        TriggerClientEvent('QBCore:Notify', src, "Donation of $" .. amount .. " sent!", "success")
                    else
                        -- Artist not found, refund the money
                        donor.Functions.AddMoney("cash", amount)
                        TriggerClientEvent('QBCore:Notify', src, "Artist not found. Donation refunded.", "error")
                    end
                end
            )
        else
            -- No database, just notify the client
            TriggerClientEvent('QBCore:Notify', src, "Donation sent!", "success")
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "Insufficient funds!", "error")
    end
end)

-- Sign record contract
RegisterNetEvent('music:server:SignRecordContract', function(contractData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local citizenid = Player.PlayerData.citizenid
    local label = contractData.label
    local contractTerms = contractData.terms
    
    if not label or label == "" then
        TriggerClientEvent('QBCore:Notify', src, "Invalid record label!", "error")
        return
    end
    
    if exports.oxmysql then
        exports.oxmysql:execute("UPDATE " .. Config.DB.ArtistsTable .. " SET record_label = ?, contract_terms = ? WHERE citizenid = ?", 
            {label, contractTerms, citizenid}, function(rowsAffected)
                if rowsAffected > 0 then
                    TriggerClientEvent('QBCore:Notify', src, "Contract signed with " .. label, "success")
                else
                    TriggerClientEvent('QBCore:Notify', src, "Failed to sign contract. Try again.", "error")
                end
            end
        )
    else
        TriggerClientEvent('QBCore:Notify', src, "Contract signed with " .. label, "success")
    end
end)

-- Buy ticket
RegisterNetEvent('music:server:BuyTicket', function(ticketData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local price = Config.DefaultTicketPrice or 50
    
    -- Apply VIP discount if configured
    if Player.PlayerData.metadata.vip and Config.VIPDiscount then
        price = price * (1 - Config.VIPDiscount)
    end
    
    if Player.Functions.RemoveMoney("cash", price) then
        -- Give player ticket item if ox_inventory is available
        if exports.ox_inventory then
            exports.ox_inventory:AddItem(src, 'concert_ticket', 1)
        end
        
        TriggerClientEvent('QBCore:Notify', src, "Ticket purchased for $" .. price .. "!", "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "Insufficient funds!", "error")
    end
end)

-- Song request
RegisterNetEvent('music:server:SongRequest', function(requestData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    if not requestData.songUrl or requestData.songUrl == "" then
        TriggerClientEvent('QBCore:Notify', src, "Invalid song URL!", "error")
        return
    end
    
    -- Broadcast to all DJs
    TriggerClientEvent('music:client:SongRequest', -1, {
        songUrl = requestData.songUrl,
        requester = requestData.requester or Player.PlayerData.charinfo.firstname
    })
    
    TriggerClientEvent('QBCore:Notify', src, "Song request sent!", "success")
end)

-- Skip current song
RegisterNetEvent('music:server:SkipSong', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- Check if player has DJ permissions
    if Player.PlayerData.job.name == "dj" or Player.PlayerData.job.name == "nightclub" then
        TriggerClientEvent('music:client:SkipSong', -1)
    else
        TriggerClientEvent('QBCore:Notify', src, "You don't have permission to skip songs!", "error")
    end
end)

-- Start rap battle
RegisterNetEvent('music:server:StartRapBattle', function(battleData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    if not Config.EventFeatures or not Config.EventFeatures.rapBattle then
        TriggerClientEvent('QBCore:Notify', src, "Rap battles are disabled!", "error")
        return
    end
    
    TriggerClientEvent('music:client:StartRapBattle', -1, {
        initiator = battleData.initiator or Player.PlayerData.charinfo.firstname
    })
end)

-- Start talk show
RegisterNetEvent('music:server:StartTalkShow', function(showData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    if not Config.EventFeatures or not Config.EventFeatures.liveTalkShow then
        TriggerClientEvent('QBCore:Notify', src, "Talk shows are disabled!", "error")
        return
    end
    
    TriggerClientEvent('music:client:StartTalkShow', -1, {
        host = showData.host or Player.PlayerData.charinfo.firstname
    })
end)

-- Update performance rating
RegisterNetEvent('music:server:UpdatePerformanceRating', function(ratingData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local citizenid = Player.PlayerData.citizenid
    local rating = tonumber(ratingData.rating)
    
    if not rating or rating < 1 or rating > (Config.PerformanceScoreUI.ratingScale or 10) then
        TriggerClientEvent('QBCore:Notify', src, "Invalid rating!", "error")
        return
    end
    
    if exports.oxmysql then
        exports.oxmysql:execute("INSERT INTO " .. Config.DB.PerformanceRatings .. " (citizenid, rating, timestamp) VALUES (?, ?, ?)", 
            {citizenid, rating, os.time()}, function(insertId)
                if insertId then
                    TriggerClientEvent('QBCore:Notify', src, "Performance rated: " .. rating, "success")
                    
                    -- Calculate and update average rating for the artist
                    exports.oxmysql:execute("SELECT AVG(rating) as avg_rating FROM " .. Config.DB.PerformanceRatings .. " WHERE citizenid = ?", 
                        {citizenid}, function(result)
                            if result and result[1] and result[1].avg_rating then
                                local avgRating = result[1].avg_rating
                                exports.oxmysql:execute("UPDATE " .. Config.DB.ArtistsTable .. " SET rating = ? WHERE citizenid = ?", 
                                    {avgRating, citizenid}
                                )
                            end
                        end
                    )
                else
                    TriggerClientEvent('QBCore:Notify', src, "Failed to save rating!", "error")
                end
            end
        )
    else
        TriggerClientEvent('QBCore:Notify', src, "Performance rated: " .. rating, "success")
    end
end)

-- Trigger stage effects
RegisterNetEvent('music:server:TriggerLightingEffects', function()
    TriggerClientEvent('music:client:TriggerLightingEffects', -1)
end)

RegisterNetEvent('music:server:TriggerFogMachine', function()
    TriggerClientEvent('music:client:TriggerFogMachine', -1)
end)

RegisterNetEvent('music:server:TriggerFireworks', function()
    TriggerClientEvent('music:client:TriggerFireworks', -1)
end)
