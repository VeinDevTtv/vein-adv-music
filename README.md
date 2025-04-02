# QBCore Music Performance System

A realistic music performance system designed for FiveM servers using QBCore. This resource enhances musician role-play and nightlife entertainment by allowing players to perform live concerts, receive donations, sign record deals, and even engage in a Guitar Hero–style mini-game during performances.

## Features

- **Live Music Performances:**  
  - Players can start a performance by providing a track URL (supports direct MP3 links and YouTube URLs).
  - Custom instrument animations (guitar, drums, piano, microphone) using FiveM natives.
  - Integration with an audio streaming resource (e.g., [xsound](https://forum.cfx.re/t/release-xsound-a-streaming-sound-system-for-fivem/)).
  - Modern, responsive UI with loading states and error handling.
  - Support for multiple simultaneous performances.

- **Crowd & Stage Effects:**  
  - Dynamic lighting using screen effects.
  - Fog machine and fireworks effects using particle FX.
  - Real-time crowd reactions and feedback system.
  - Customizable stage props and decorations.
  
- **Musician Career & Record Labels:**  
  - Record contracts can be signed with custom record labels.
  - Database integration to store artist data and performance history.
  - Performance ratings and crowd feedback system.
  - Artist profiles and statistics tracking.
  
- **Monetization & Economy:**  
  - Donation system for live performances.
  - Concert ticket sales and merchandise integration.
  - VIP access system with exclusive features.
  - Revenue sharing system for venues.
  
- **Playable Instrument Mini-Game:**  
  - A Guitar Hero–style mini-game where players hit notes (using the [E] key) to boost their performance score.
  - Real-time performance tracking and scoring system.
  - Multiple difficulty levels and song patterns.

- **Compatibility:**  
  - Fully compatible with QBCore and integrates with dependencies like ox_mysql, ox_inventory, and ox_lib.
  - Designed to work with the latest versions of QBCore.
  - Responsive design that works on all screen sizes.
  - Support for both standalone and framework-integrated use.

## System Requirements

### Server Requirements
- FiveM Server (Build 5552 or higher)
- QBCore Framework (Latest version)
- MySQL 5.7 or higher
- 2GB RAM minimum
- 1GB storage space

### Dependencies
- oxmysql (Latest version)
- ox_inventory (Latest version)
- ox_lib (Latest version)
- xsound (or compatible audio streaming resource)
- qb-core (Latest version)

### Client Requirements
- FiveM Client (Latest version)
- 4GB RAM minimum
- DirectX 11 compatible graphics card

### Development Requirements
- Node.js 16.x or higher
- npm 7.x or higher
- Git

## Installation & Setup

1. **Resource Installation:**
   ```bash
   # Clone the repository
   git clone https://github.com/yourusername/vein-adv-music.git
   
   # Copy to your server's resources folder
   cp -r vein-adv-music /path/to/your/server/resources/
   ```

2. **UI Setup:**
   ```bash
   # Navigate to the UI directory
   cd vein-adv-music/vein-adv-music-ui
   
   # Install dependencies
   npm install
   
   # Build the UI
   npm run build
   ```

3. **Database Setup:**
   The script will automatically create the necessary database tables on first run, but you can also manually set them up using the SQL below:
   ```sql
   -- Import the following SQL into your database
   CREATE TABLE IF NOT EXISTS `music_artists` (
       `id` INT(11) NOT NULL AUTO_INCREMENT,
       `citizenid` VARCHAR(50) NOT NULL,
       `artist_name` VARCHAR(100) NOT NULL,
       `record_label` VARCHAR(100) DEFAULT NULL,
       `contract_terms` TEXT DEFAULT NULL,
       `total_performances` INT(11) DEFAULT 0,
       `total_earnings` DECIMAL(10,2) DEFAULT 0.00,
       `rating` DECIMAL(3,2) DEFAULT 0.00,
       PRIMARY KEY (`id`),
       UNIQUE KEY `citizenid` (`citizenid`)
   ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

   CREATE TABLE IF NOT EXISTS `music_concerts` (
       `id` INT(11) NOT NULL AUTO_INCREMENT,
       `artist_id` INT(11) NOT NULL,
       `track_url` VARCHAR(255) NOT NULL,
       `performance_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
       `duration` INT(11) DEFAULT 0,
       `score` INT(11) DEFAULT 0,
       `earnings` DECIMAL(10,2) DEFAULT 0.00,
       PRIMARY KEY (`id`),
       FOREIGN KEY (`artist_id`) REFERENCES `music_artists`(`id`) ON DELETE CASCADE
   ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
   ```

4. **Server Configuration:**
   Add the following to your `server.cfg`:
   ```cfg
   # Music Performance System
   ensure vein-adv-music
   
   # Dependencies
   ensure oxmysql
   ensure ox_inventory
   ensure ox_lib
   ensure qb-core
   ensure xsound
   ```

## Detailed Tutorial

### Getting Started as a Performer

1. **Finding a Venue**
   - Look for designated performance areas in clubs, bars, or outdoor stages
   - Some venues may require permission or booking through venue staff
   - Public spaces are generally open for impromptu performances

2. **Choosing Your Instrument**
   - Each instrument has different animations and skill multipliers:
     - Guitar (Default): Balanced performance with standard scoring
     - Drums: Higher skill multiplier (1.2x) but more challenging timing
     - Piano: Good skill multiplier (1.1x) with medium difficulty
     - Microphone: Standard scoring, focus on vocals
     - DJ: Highest skill multiplier (1.3x) with special mixing controls

3. **Starting Your First Performance**
   - Find a suitable location
   - Prepare a valid track URL (YouTube or direct MP3)
   - Use the command:
     ```
     /startperformance [track URL] [instrument]
     ```
   - Example:
     ```
     /startperformance https://www.youtube.com/watch?v=dQw4w9WgXcQ guitar
     ```

4. **During the Performance**
   - The mini-game will automatically start
   - Watch for the "Hit the note!" prompts
   - Press [E] when prompted to hit notes
   - Time your hits precisely - perfect timing gives 1.5x points!
   - Interact with the crowd periodically (using [H] or UI buttons)
   - Use special effects to enhance your performance (using [J] or UI)

5. **Ending Your Performance**
   - Your performance will end automatically after all notes are played
   - You can manually end it with:
     ```
     /stopperformance
     ```
   - After ending, you'll be prompted to rate the performance
   - Performance data (duration, score) is saved to the database

### Understanding the Performance Mini-Game

The mini-game is a rhythm-based system similar to Guitar Hero:

1. **Basic Mechanics**
   - Notes appear at timed intervals
   - Press [E] when prompted to hit the note
   - Each successful hit earns you points
   - Missed notes don't deduct points but affect crowd mood

2. **Scoring System**
   - Base score per note: 10 points
   - Perfect timing (within first 30% of timing window): 1.5x multiplier
   - Instrument skill multiplier applies to all points
   - Consecutive hits build combos (if enabled in config)

3. **Difficulty Levels**
   - Easy: Slower notes (0.7x speed), standard points
   - Medium (Default): Normal speed, 1.5x points
   - Hard: Faster notes (1.3x speed), 2x points
   
   To set difficulty (server owners only):
   ```lua
   Config.MiniGame.defaultDifficulty = "medium" -- Options: "easy", "medium", "hard"
   ```

4. **Crowd Reactions**
   - Maintaining high scores keeps the crowd engaged
   - Inactivity for 8 seconds triggers crowd boredom warnings
   - Continued inactivity will end your performance prematurely
   - Donations boost crowd mood

### DJ Mode Tutorial

DJ mode offers special features for club DJs:

1. **Activating DJ Mode**
   ```
   /djmode on
   ```

2. **DJ Deck Controls**
   - Access the DJ interface with:
     ```
     /djcontrols
     ```
   - Features include:
     - Volume control
     - Crossfading between tracks
     - Effects (boost bass, filters, etc.)
     - Visualizer types (wave, bar, circle)

3. **Managing Song Requests**
   - View pending requests:
     ```
     /djqueue
     ```
   - Accept or reject requests through the UI
   - Play the next requested song with:
     ```
     /skipsong
     ```

4. **DJ Performance Tips**
   - Use crossfade for smooth transitions
   - Apply effects at key moments
   - Respond to audience requests
   - Use visualizers that match the music style

### Special Events

1. **Rap Battles**
   - Challenge another player:
     ```
     /rapbattle [player ID or name]
     ```
   - The challenged player can accept with:
     ```
     /acceptbattle
     ```
   - Battle consists of alternating freestyle performances
   - Audience votes for the winner

2. **Talk Shows**
   - Start a talk show:
     ```
     /talkshow start
     ```
   - Invite guests through the UI
   - Audience can react with:
     ```
     /audience react [cheer/laugh/boo]
     ```

3. **Festival Mode**
   - Server admins can activate festival mode:
     ```
     /festivalmode start
     ```
   - Multiple stages become available
   - Special weather and visual effects activate
   - Enhanced crowd sizes
   - To trigger special festival effects:
     ```
     /festivaleffects [fireworks/confetti/strobe]
     ```

### VIP Features

1. **Obtaining VIP Status**
   - Purchase through configured shop or admin grant
   - Default cost: $500
   - Lasts for 7 days (configurable)

2. **VIP Benefits**
   - Backstage access to exclusive areas
   - Discounted tickets (20% by default)
   - Priority performance queue
   - Exclusive items and effects
   - Check benefits with:
     ```
     /vipbenefits
     ```

3. **Using VIP Access**
   ```
   /vipaccess
   ```

## Advanced Configuration Guide

### Economy Configuration

Adjust the following in `config.lua` to balance your server's economy:

```lua
Config.Economy = {
    DefaultDonationSplit = 0.7,            -- Artist's share of donations
    VenueOwnerShare = 0.3,                 -- Venue's share of ticket sales
    DefaultTicketPrice = 50,               -- Base ticket price
    DonationMinAmount = 10,                -- Minimum donation amount
    DonationMaxAmount = 1000,              -- Maximum donation amount
    VenueRentalCost = 200,                 -- Cost to rent a venue
    MerchMarkup = 0.8                      -- Merchandise profit margin
}
```

### Performance Optimization

For servers with performance concerns:

```lua
Config.PerformanceOptimization = {
    LimitEffectsRange = 50.0,              -- Maximum effect render distance
    MaxSimultaneousEffects = 3,            -- Limit concurrent effects
    GpuParticleLimit = 100,                -- Maximum particles
    ReduceEffectsOnLowFPS = true           -- Auto-reduce effects at low FPS
}
```

### Mini-Game Customization

Adjust difficulty and gameplay:

```lua
Config.MiniGame = {
    enabled = true,                        -- Enable/disable mini-game
    totalNotes = 15,                       -- Notes per performance
    noteTimingWindow = 1000,               -- MS to hit each note
    scorePerNote = 10,                     -- Base points per note
    perfectHitBonus = 5,                   -- Extra points for perfect timing
    comboMultiplier = true,                -- Enable combo system
    difficultyLevels = {
        easy = { speed = 0.7, points = 1.0 },
        medium = { speed = 1.0, points = 1.5 },
        hard = { speed = 1.3, points = 2.0 }
    },
    defaultDifficulty = "medium"           -- Default difficulty
}
```

## Troubleshooting Guide

### Common Issues and Solutions

1. **Audio Not Playing**
   - **Problem**: Track doesn't play when starting performance
   - **Solutions**:
     - Ensure xsound is properly installed and running
     - Check if the URL is valid and accessible
     - Try using a different audio format or host
     - Verify the volume settings in config.lua

2. **Animations Not Working**
   - **Problem**: Character doesn't perform instrument animation
   - **Solutions**:
     - Ensure animation dictionaries are valid
     - Try a different instrument
     - Check for animation conflicts with other resources
     - Restart the client if animations get stuck

3. **Database Errors**
   - **Problem**: Performance data not saving
   - **Solutions**:
     - Verify oxmysql is properly installed
     - Check database connection settings
     - Ensure tables exist with correct structure
     - Look for SQL errors in server console

4. **UI Issues**
   - **Problem**: UI not appearing or responsive
   - **Solutions**:
     - Make sure UI is built properly (`npm run build`)
     - Check for JavaScript errors in browser console (F8)
     - Clear browser cache with `/clearnui`
     - Verify NUI callbacks are properly registered

5. **Performance Lag**
   - **Problem**: Server or client lag during performances
   - **Solutions**:
     - Reduce particle effects in config
     - Lower the MaxSimultaneousEffects setting
     - Enable ReduceEffectsOnLowFPS option
     - Limit the number of concurrent performances

### Server Owner Diagnostics

Run these commands as a server owner to diagnose issues:

```
/musicdebug on       # Enable detailed logging
/musicstatus         # View system status and active performances
/musicreset          # Reset any stuck performances (emergency use only)
/musicrepair         # Attempt to repair database issues
```

## Support & Community

- **Discord:** [Join our Discord server](https://discord.gg/your-invite)
- **GitHub Issues:** [Report bugs or request features](https://github.com/yourusername/vein-adv-music/issues)
- **Documentation:** [Wiki](https://github.com/yourusername/vein-adv-music/wiki)
- **Support Email:** support@yourdomain.com

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

- QBCore Framework
- ox_lib
- ox_inventory
- oxmysql
- xsound
- All contributors and supporters

## Changelog

### v1.0.0
- Initial release
- Basic performance system
- UI implementation
- Database integration

### v1.1.0
- Added VIP features
- Enhanced UI responsiveness
- Added crowd interaction system
- Improved performance tracking

### v1.2.0
- Added festival mode
- Enhanced effects system
- Added revenue sharing
- Improved database structure
