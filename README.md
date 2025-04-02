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

4. **Configuration:**
   - Copy `config.example.lua` to `config.lua`
   - Update the following settings in `config.lua`:
     ```lua
     Config = {}
     
     -- General Settings
     Config.Debug = false
     Config.DefaultVolume = 0.5
     Config.MaxSimultaneousPerformances = 3
     
     -- Economy Settings
     Config.TicketPrice = 100
     Config.DonationMinAmount = 10
     Config.DonationMaxAmount = 1000
     Config.VenueShare = 0.3 -- 30% of earnings go to venue
     
     -- Performance Settings
     Config.MaxPerformanceDuration = 3600 -- 1 hour in seconds
     Config.MinPerformanceDuration = 300 -- 5 minutes in seconds
     
     -- VIP Settings
     Config.VIPDiscount = 0.2 -- 20% discount for VIP members
     Config.VIPExclusiveLocations = true
     
     -- Database Settings
     Config.Database = {
         TablePrefix = "music_",
         AutoCleanup = true,
         CleanupInterval = 7 -- days
     }
     ```

5. **Server Configuration:**
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

## Usage Guide

### Commands

1. **Basic Performance:**
   ```
   /startperformance [track URL] [instrument]
   /stopperformance
   /performancehelp
   ```

2. **DJ Mode:**
   ```
   /djmode [on/off]
   /djcontrols
   /djqueue
   ```

3. **Rap Battle:**
   ```
   /rapbattle [opponent]
   /acceptbattle
   /declinebattle
   ```

4. **Talk Show:**
   ```
   /talkshow [start/stop]
   /audience [react/leave]
   ```

5. **Festival Mode:**
   ```
   /festivalmode [start/stop]
   /festivaleffects
   ```

6. **VIP Commands:**
   ```
   /vipaccess
   /vipbenefits
   /vipqueue
   ```

### Key Bindings
- `[E]` - Hit notes during performance
- `[F]` - Toggle performance UI
- `[G]` - Toggle instrument selection
- `[H]` - Toggle crowd interaction
- `[J]` - Toggle effects menu

### Performance Tips

1. **Getting Started:**
   - Choose your instrument type
   - Select a suitable location
   - Ensure you have the required permissions
   - Check your equipment status

2. **During Performance:**
   - Watch for the note prompts
   - Time your [E] key presses with the music
   - Interact with the crowd using the UI
   - Monitor your performance score
   - Use effects strategically

3. **Maximizing Tips:**
   - Maintain high performance scores
   - Engage with the crowd
   - Use special effects strategically
   - Choose popular songs
   - Perform during peak hours

## Development

### UI Development
```bash
# Start development server
cd vein-adv-music-ui
npm run dev

# Build for production
npm run build

# Run tests
npm test
```

### Adding New Features

1. **New UI Component:**
   - Create a new component in `src/components/`
   - Import and add to `App.jsx`
   - Update the state management in `App.jsx`
   - Add necessary styles

2. **New Server Feature:**
   - Add server-side logic in `server.lua`
   - Update database schema if needed
   - Add client-side handlers in `client.lua`
   - Update configuration options

## Troubleshooting

### Common Issues

1. **Performance Not Starting:**
   - Check if the track URL is valid
   - Ensure you have the required permissions
   - Verify the audio streaming resource is running
   - Check server console for errors
   - Verify database connection

2. **UI Not Loading:**
   - Check browser console for errors
   - Verify the build process completed successfully
   - Ensure all dependencies are installed
   - Clear browser cache
   - Check NUI callback registration

3. **Database Issues:**
   - Verify database connection settings
   - Check if tables are created correctly
   - Ensure proper permissions are set
   - Check for SQL errors in server console
   - Verify database user permissions

4. **Audio Issues:**
   - Check xsound configuration
   - Verify audio permissions
   - Check for conflicting audio resources
   - Verify audio file format compatibility

## Support & Contributions

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
