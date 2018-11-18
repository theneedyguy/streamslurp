# Streamslurp

A docker container to automatically download the latest vod of your favourite twitch streamer.

## Howto

The container expects 3 environment variables:

- STR_KEY (Your Twitch API key.)
- STR_CHANNEL (The name of the twitch channel you want to auto download)
- STR_RES (The default resolution of the vod)

The container has a volume at /opt/streamslurp/vods.
If you point a directory to this path you can save the vods directly into that directory (As a Docker user you should naturally understand).
