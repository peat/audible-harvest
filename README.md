# Audible Harvest

Monitor all your social networks for music activity, find out what your friends are listening to, and who listened to it first.

## Disclaimer

Yo, this is in serious development right now. Music Hack Day ends on the evening of February 12th. Don't expect anything to work until then.

## Parts

- `extension/` contains a Chrome extension for monitoring Facebook and Twitter streams.
- `server/` contains a Sinatra server for spidering links and aggregating stats.
- `irc/` contains a bot for monitoring an IRC channel.

## What It Collects

- Facebook: listening shares from Spotify, Turntable.fm, Rhapsody, MOG, and Rdio
- Twitter: links to SoundCloud, Spotify, and (some) Tumblr audio posts.
- IRC: links to SoundCloud, Spotify, and (some) Tumblr audio posts.

## Usage

- Good luck!
