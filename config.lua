-- config.lua
Config = {}

-- General settings
Config.DefaultDonationSplit = 0.7  -- 70% goes to the artist
Config.DefaultTicketPrice = 50       -- Ticket price in in-game currency
Config.DefaultMerchRevenue = 0.8     -- 80% revenue for merch sales

-- Database tables (ensure these tables exist in your DB)
Config.DB = {
    ArtistsTable = "music_artists",
    ConcertsTable = "music_concerts",
    DonationsTable = "music_donations",
    MerchandiseTable = "music_merch",
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

-- API Keys (for YouTube/SoundCloud advanced integration)
Config.YouTubeAPIKey = "YOUR_YOUTUBE_API_KEY"

-- UI settings
Config.UIModernTheme = true

-- Mini-game settings for instrument play (Guitar Hero-style)
Config.MiniGame = {
    noteTimingWindow = 1000,  -- milliseconds allowed to hit a note
    scorePerNote = 10,
    totalNotes = 10,
}
