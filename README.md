# Streamslurp

A docker container to automatically download the latest vod of your favourite twitch streamer.
It uses streamlink as the interface to connect to twitch and download the vods.

## Howto

The container expects 3 environment variables:

- STR_KEY (Your Twitch API key.)
- STR_CHANNEL (The name of the twitch channel you want to auto download)
- STR_RES (The default resolution of the vod)

### Resolutions

Valid resolutions may vary since streamers are free to set it and what framerates they use.
There are the following resolutions that have been tested:

- 160p
- 360p
- 480p
- 720p
- 720p60
- 1080p60

If you set one of these resolutions as the value for STR_RES the container should download the vod. If the resoluton does not exist it will automatically download the best available resolution.

## Notes

The container has a volume at /opt/streamslurp/vods.
If you point a directory to this path you can save the vods directly into that directory (As a Docker user you should naturally understand).
