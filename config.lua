-- config.lua
Config = {}

--[[ 
    GENERAL SETTINGS
    Control overall system behavior and performance
]]
Config.Debug = false                        -- Enable debug mode with extra logging and on-screen information
Config.DefaultVolume = 0.5                  -- Default audio volume (0.0 - 1.0)
Config.PerformanceOptimization = {
    LimitEffectsRange = 50.0,              -- Maximum distance to render visual effects (meters)
    MaxSimultaneousEffects = 3,            -- Maximum number of effects that can play at once
    GpuParticleLimit = 100,                -- Maximum GPU particles to render
    ReduceEffectsOnLowFPS = true           -- Automatically reduce effects on low FPS
}

--[[ 
    ECONOMY SETTINGS
    Configure monetization aspects
]]
Config.Economy = {
    DefaultDonationSplit = 0.7,            -- 70% goes to the artist, 30% to the venue
    VenueOwnerShare = 0.3,                 -- Percentage of ticket sales for venue owner
    DefaultTicketPrice = 50,               -- Price for concert tickets
    DonationMinAmount = 10,                -- Minimum allowed donation
    DonationMaxAmount = 1000,              -- Maximum allowed donation
    VenueRentalCost = 200,                 -- Cost to rent a venue for a performance
    MerchMarkup = 0.8                      -- 80% markup on merchandise
}

--[[ 
    DATABASE SETTINGS
    Configure persistence and data storage
]]
Config.DB = {
    ArtistsTable = "music_artists",
    ConcertsTable = "music_concerts",
    DonationsTable = "music_donations",
    MerchandiseTable = "music_merch",
    PerformanceRatings = "music_performance_ratings"
}

Config.Database = {
    TablePrefix = "music_",                -- Prefix for all tables
    AutoCleanup = true,                    -- Auto-clean old records
    CleanupInterval = 30,                  -- Days to keep records before cleanup
    BackupFrequency = 24,                  -- Hours between database backups (0 to disable)
    UseTransactions = true                 -- Use transactions for better data consistency
}

--[[ 
    INSTRUMENT SETTINGS
    Animation dictionaries, names, and prop models for instruments
]]
Config.Instruments = {
    guitar = { 
        animDict = "amb@world_human_musician@guitar@male@base", 
        animName = "base", 
        model = "prop_acc_guitar_01",
        audioVisualizers = true,           -- Enable audio visualizers for this instrument
        skillMultiplier = 1.0              -- Skill multiplier for scoring
    },
    drums = { 
        animDict = "amb@world_human_musician@drum@male@base", 
        animName = "base", 
        model = "prop_drum_01",
        audioVisualizers = true,
        skillMultiplier = 1.2
    },
    piano = { 
        animDict = "amb@world_human_musician@piano@male@base", 
        animName = "base", 
        model = "prop_piano_01",
        audioVisualizers = true,
        skillMultiplier = 1.1
    },
    microphone = { 
        animDict = "missfam5_yoga", 
        animName = "a_yoga_pose", 
        model = "prop_microphone_01",
        audioVisualizers = false,
        skillMultiplier = 1.0
    },
    dj = { 
        animDict = "anim@mp_player_intupperair_synth", 
        animName = "enter", 
        model = "prop_dj_deck_01",
        audioVisualizers = true,
        skillMultiplier = 1.3
    }
}

--[[ 
    DJ SYSTEM SETTINGS
    Configure DJ deck functionality
]]
Config.DJSystem = {
    turntableUI = true,                    -- Enable DJ turntable UI
    volumeStep = 0.1,                      -- Volume control increment/decrement step
    crossfadeTime = 2.0,                   -- Time in seconds for crossfade between tracks
    effectsEnabled = true,                 -- Enable sound effects (e.g., filters, echo)
    visualizerTypes = {"wave", "bar", "circle"}, -- Available visualizer types
    allowSongRequests = true,              -- Allow audience to request songs
    autoMixEnabled = true                  -- Enable auto-mixing feature
}

--[[ 
    STAGE EFFECTS SETTINGS
    Visual and particle effects
]]
Config.StageEffects = {
    dynamicLighting = true,                -- Enable dynamic stage lighting
    fogMachine = true,                     -- Enable fog machine effects
    fireworks = true,                      -- Enable firework effects
    strobeLight = true,                    -- Enable strobe light effects
    confetti = true,                       -- Enable confetti particle effects
    pyrotechnics = true,                   -- Enable pyrotechnic effects
    crowdEffects = true,                   -- Enable crowd animation effects
    effectsCooldown = 10                   -- Seconds between triggering special effects
}

--[[ 
    PERFORMANCE DYNAMICS
    Configure performance behavior and audience reaction
]]
Config.DynamicStage = {
    idleTimeThreshold = 8000,              -- ms before crowd loses interest (default: 8 seconds)
    crowdMoodMultiplier = 1.5,             -- Score multiplier for good crowd mood
    audienceSize = {                       -- Audience size parameters
        min = 5,                           -- Minimum audience size
        max = 50,                          -- Maximum audience size 
        scaling = true                     -- Dynamically scale based on server population
    },
    crowdReactions = {                     -- Configure crowd reactions
        enabled = true,                    -- Enable crowd reactions
        types = {"cheer", "applause", "boo", "request"}, -- Available reaction types
        frequency = 15,                    -- Seconds between random reactions
        reactionChance = 0.3               -- Chance (0.0-1.0) of reaction occurring
    }
}

--[[ 
    SONG REQUEST SYSTEM
]]
Config.SongRequests = {
    maxRequests = 5,                       -- Maximum pending requests
    requestCooldown = 60,                  -- Seconds between allowed requests per player
    requirePayment = false,                -- Require payment for requests
    requestCost = 10,                      -- Cost for song requests if payment required
    allowDJToCensor = true                 -- Allow DJ to block inappropriate requests
}

--[[ 
    AUDIO PROCESSING SETTINGS
]]
Config.AudioProcessing = {
    AutoSync = {
        enabled = true,                    -- Enable auto-sync between clients
        syncInterval = 5000                -- ms between sync checks
    },
    AudioCaching = {
        enabled = true,                    -- Enable server-side audio caching
        cacheDuration = 3600,              -- Seconds to cache audio (1 hour)
        maxCacheSize = 100                 -- Maximum number of cached tracks
    },
    LiveMic = {
        enabled = true,                    -- Enable live microphone integration
        autoGain = true,                   -- Enable auto gain control
        noiseReduction = true,             -- Enable noise reduction
        proximityRange = 20.0              -- Range for proximity voice effects (meters)
    },
    Equalizer = {
        enabled = true,                    -- Enable equalizer
        presets = {"pop", "rock", "edm", "hiphop"} -- Available equalizer presets
    }
}

--[[ 
    MINI-GAME SETTINGS
    Configure the Guitar Hero-style mini-game
]]
Config.MiniGame = {
    enabled = true,                        -- Enable the mini-game
    totalNotes = 15,                       -- Total notes in a performance
    noteTimingWindow = 1000,               -- Time window to hit a note (ms)
    scorePerNote = 10,                     -- Base score per correct note
    perfectHitBonus = 5,                   -- Additional points for perfect timing
    comboMultiplier = true,                -- Enable combo multiplier
    difficultyLevels = {                   -- Difficulty levels
        easy = { speed = 0.7, points = 1.0 },
        medium = { speed = 1.0, points = 1.5 },
        hard = { speed = 1.3, points = 2.0 }
    },
    defaultDifficulty = "medium"           -- Default difficulty level
}

--[[ 
    SPECIAL EVENT FEATURES
]]
Config.EventFeatures = {
    rapBattle = true,                      -- Enable rap battle feature
    randomEventChance = 0.1,               -- Chance of random events occurring
    liveTalkShow = true,                   -- Enable talk show feature
    awardCeremony = true,                  -- Enable music awards ceremony
    audienceChallenge = true,              -- Allow audience to challenge performers
    specialGuests = true                   -- Enable special guest appearances
}

--[[ 
    UI SETTINGS
]]
Config.PerformanceScoreUI = {
    ratingScale = 10,                      -- Rating scale (1-10)
    showRealTimeScore = true,              -- Show score in real-time
    scoreDisplayTime = 3,                  -- Seconds to display score updates
    dynamicUI = true,                      -- UI adapts based on performance
    hudElements = {                        -- HUD elements to display
        crowd = true,
        score = true,
        timer = true,
        effects = true
    }
}

--[[ 
    FESTIVAL MODE SETTINGS
]]
Config.VirtualFestival = {
    enabled = true,                        -- Enable festival mode
    maxStages = 3,                         -- Maximum simultaneous stages
    durationHours = 3,                     -- Default festival duration in hours
    autoSchedule = true,                   -- Auto-schedule performers
    weatherEffects = true,                 -- Enable special weather during festivals
    festivalPerks = {                      -- Special perks during festivals
        freeFood = true,
        specialItems = true,
        uniqueClothing = true
    }
}

--[[ 
    VIP SYSTEM
]]
Config.VIPPass = {
    enabled = true,                        -- Enable VIP system
    cost = 500,                            -- Cost of VIP access
    duration = 7,                          -- Days VIP access lasts
    perks = {                              -- VIP perks
        backstageAccess = true,
        exclusiveItems = true,
        noWaitTimes = true,
        discounts = 0.2                    -- 20% discount on purchases
    }
}

--[[ 
    COMPETITIVE FEATURES
]]
Config.Competitive = {
    liveArtistRankings = true,             -- Enable live artist rankings
    musicAwards = true,                    -- Enable music awards
    seasonalEvents = true,                 -- Enable seasonal competitions
    achievements = {                       -- Artist achievements
        enabled = true,
        types = {"platinumArtist", "crowdFavorite", "risingStart", "legendaryPerformer"}
    },
    leaderboards = {                       -- Leaderboard types
        weeklyTop = true,
        allTimeGreats = true,
        genreSpecific = true
    }
}
