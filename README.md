# QBCore Music Performance System

A realistic music performance system designed for FiveM servers using QBCore. This resource enhances musician role-play and nightlife entertainment by allowing players to perform live concerts, receive donations, sign record deals, and even engage in a Guitar Hero–style mini-game during performances.

## Features

- **Live Music Performances:**  
  - Players can start a performance by providing a track URL (supports direct MP3 links and YouTube URLs).
  - Custom instrument animations (guitar, drums, piano, microphone) using FiveM natives.
  - Integration with an audio streaming resource (e.g., [xsound](https://forum.cfx.re/t/release-xsound-a-streaming-sound-system-for-fivem/)).

- **Crowd & Stage Effects:**  
  - Dynamic lighting using screen effects.
  - Fog machine and fireworks effects using particle FX.
  
- **Musician Career & Record Labels:**  
  - Record contracts can be signed with custom record labels.
  - Database integration to store artist data and performance history.
  
- **Monetization & Economy:**  
  - Donation system for live performances.
  - Concert ticket sales and merchandise integration.
  
- **Playable Instrument Mini-Game:**  
  - A Guitar Hero–style mini-game where players hit notes (using the [E] key) to boost their performance score.

- **Compatibility:**  
  - Fully compatible with QBCore and integrates with dependencies like ox_mysql, ox_inventory, and ox_lib.
  - Designed to work with the latest versions of QBCore.

## File Structure

```
vein-adv-music/
├── fxmanifest.lua
├── config.lua
├── client.lua
├── server.lua
└── html
    ├── index.html
    ├── style.css
    └── script.js
```

- **fxmanifest.lua:** Resource manifest defining the resource metadata and file dependencies.
- **config.lua:** Configuration file containing all customizable settings (ticket prices, donation splits, instrument settings, stage effects, etc.).
- **client.lua:** Contains all client-side logic:
  - Initiates performances.
  - Plays audio and animations.
  - Triggers stage effects.
  - Runs the mini-game.
- **server.lua:** Contains server-side logic:
  - Handles performance data storage.
  - Processes donations, ticket purchases, and record contracts.
  - Broadcasts stage effects to all clients.
- **html folder:** Contains the modern UI for the performance system.

## Database Setup

To integrate with your MySQL database, create the following tables. This script uses [oxmysql](https://github.com/overextended/oxmysql) for database operations.

```sql
-- Table to store artist information
CREATE TABLE IF NOT EXISTS `music_artists` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `citizenid` VARCHAR(50) NOT NULL,
    `artist_name` VARCHAR(100) NOT NULL,
    `record_label` VARCHAR(100) DEFAULT NULL,
    `contract_terms` TEXT DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table to store concert performances
CREATE TABLE IF NOT EXISTS `music_concerts` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `artist_id` INT(11) NOT NULL,
    `track_url` VARCHAR(255) NOT NULL,
    `performance_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`artist_id`) REFERENCES `music_artists`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table to store donations made to artists
CREATE TABLE IF NOT EXISTS `music_donations` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `artist_id` INT(11) NOT NULL,
    `donor_name` VARCHAR(100) NOT NULL,
    `amount` DECIMAL(10,2) NOT NULL,
    `donation_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`artist_id`) REFERENCES `music_artists`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table to store merchandise sales
CREATE TABLE IF NOT EXISTS `music_merch` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `artist_id` INT(11) NOT NULL,
    `item_name` VARCHAR(100) NOT NULL,
    `price` DECIMAL(10,2) NOT NULL,
    `stock` INT(11) NOT NULL,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`artist_id`) REFERENCES `music_artists`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

## Installation & Setup

1. **Dependencies:**
   - Ensure you have the latest versions of QBCore, ox_mysql, ox_inventory, ox_lib, and an audio streaming resource such as xsound.
   - For YouTube integration, obtain a valid YouTube API key and set it in `config.lua`.

2. **Resource Installation:**
   - Place the resource folder (e.g., `vein-adv-music`) in your server's `resources` directory.
   - Add `ensure vein-adv-music` (or `start vein-adv-music`) to your server configuration file (server.cfg).

3. **Database Configuration:**
   - Import the provided SQL code into your MySQL database to create the necessary tables.
   - Update your database connection details if required.

4. **Configuration:**
   - Customize `config.lua` for your server’s economy, instrument settings, stage effects, and mini-game configurations.
   - Adjust the UI in the `html` folder if needed.

## How to Use

### Starting a Performance

- **Command:**  
  Players can initiate a performance using the in-game command:  
  ```
  /startperformance [track URL]
  ```
  For example:
  ```
  /startperformance https://www.youtube.com/watch?v=example
  ```

- **What Happens:**
  - The performance UI will open.
  - The specified track is played using your audio streaming resource.
  - The player's character will perform an animation corresponding to the selected instrument.
  - Stage effects (lighting, fog, fireworks) will trigger.
  - The mini-game starts, prompting the player to hit notes using the [E] key.

## Support & Contributions

Feel free to contribute improvements or report issues on the repository. Enjoy building an immersive musician role-play and nightlife experience on your FiveM server!
