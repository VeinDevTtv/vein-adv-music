-- config.lua
Config = {}

-- General settings
Config.DefaultDonationSplit = 0.7       -- 70% goes to the artist
Config.DefaultTicketPrice = 50            -- Ticket price in in-game currency
Config.DefaultMerchRevenue = 0.8          -- 80% revenue for merch sales

-- Database tables (ensure these tables exist in your DB)
Config.DB = {
    ArtistsTable = "music_artists",
    ConcertsTable = "music_concerts",
    DonationsTable = "music_donations",
    MerchandiseTable = "music_merch",
    PerformanceRatings = "music_performance_ratings",
}

-- Instrument settings: defines animation dictionaries, animation names, and associated prop models
Config.Instruments = {
    guitar = { animDict = "amb@world_human_musician@guitar@male@base", animName = "base", model = "prop_acc_guitar_01" },
    drums = { animDict = "amb@world_human_musician@drum@male@base", animName = "base", model = "prop_drum_01" },
    piano = { animDict = "amb@world_human_musician@piano@male@base", animName = "base", model = "prop_piano_01" },
    microphone = { animDict = "missfam5_yoga", animName = "a_yoga_pose", model = "prop_microphone_01" },
}

-- DJ Booth settings
Config.DJBooth = {
    volumeStep = 0.1,
    crossfadeTime = 2.0,  -- seconds
}

-- Stage Effects settings
Config.StageEffects = {
    dynamicLighting = true,
    fogMachine = true,
    fireworks = true,
}

-- Additional Features Configurations

-- More Realistic Performance System
Config.DynamicStage = {
    idleTimeThreshold = 5000, -- milliseconds of inactivity before crowd loses interest
}

Config.SongRequests = {
    maxRequests = 5,
}

Config.AutoSync = {
    enabled = true,  -- if multiple artists are performing, try to sync animations and music
}

-- Advanced Streaming & Audio Processing
Config.AudioCaching = {
    enabled = true,
    cacheDuration = 3600, -- seconds to cache a frequently played song
}

Config.LiveMic = {
    enabled = true,  -- enable real-time voice for live freestyle/commentary (requires additional integration)
}

-- Event-Based Features
Config.EventFeatures = {
    rapBattle = true,
    randomEventChance = 0.1, -- chance to trigger a random event during performance
    liveTalkShow = true,
}

-- Performance Score UI (rating scale 1-10)
Config.PerformanceScoreUI = {
    ratingScale = 10,
}

-- Immersive Nightlife Experience
Config.DJSystem = {
    turntableUI = true,
}

Config.VirtualFestival = {
    enabled = true,
}

Config.VIPPass = {
    enabled = true,
}

-- Competitive & Social Features
Config.Competitive = {
    liveArtistRankings = true,
    musicAwards = true,
}
