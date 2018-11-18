#!/bin/bash

# Streamlink helper script for downloading vods automatically.
# You will need to create a Twitch API key for this to work since it relies on the API.
# Version 1.0
# Author theneedyguy
# LICENSE: MIT


# Source the virtualenv (only for testing outside of container)
#. ./venv/bin/activate

# Set variables
KEY=$STR_KEY
CHANNEL=$STR_CHANNEL
DESIRED_RES=$STR_RES

# To avoid downloading the current stream that might not even be finished we download the second latest vod of the streamer.
# This will have problems if the streamer has never streamed before but who really cares. This is just a little script.
STREAMSTATUS=$(curl -s -H "Client-ID: $KEY" -X GET "https://api.twitch.tv/kraken/streams/$CHANNEL" | jq .stream.stream_type)
if [ $STREAMSTATUS == "null" ]
then
    echo "Streamer offline. Downloading latest vod."
    LATEST_VOD=$(curl -s -H "Client-ID: $KEY" -X GET "https://api.twitch.tv/kraken/channels/$CHANNEL/videos?broadcast_type=archive" | jq '.videos[0] | {url: .url, created_at: .created_at, resolutions: .resolutions}')
else
    echo "Streamer is streaming. Downloading last vod that is not the current stream."
    LATEST_VOD=$(curl -s -H "Client-ID: $KEY" -X GET "https://api.twitch.tv/kraken/channels/$CHANNEL/videos?broadcast_type=archive" | jq '.videos[1] | {url: .url, created_at: .created_at, resolutions: .resolutions}')
fi

QUALITY=$(echo $LATEST_VOD | jq '.resolutions')
DATE=$(echo $LATEST_VOD | jq '.created_at' | sed 's/\"//g')
URL=$(echo $LATEST_VOD | jq '.url' | sed 's/\"//g')

FILE_DATE=$(date -u -D %Y-%m-%dT%TZ -d $DATE +%s)
echo $FILE_DATE
echo $(date -d "@$FILE_DATE" +%Y-%m-%d-%H:%M)
VOD_DATE=$(date -d "@$FILE_DATE" +%Y-%m-%d-%H:%M)


# Helper function to check if a value is in an array
containsElement () {
    local e match="$1"
    shift
    for e; do [[ "$e" == "$match" ]] && return 0; done
    return 1
}

# Create new array with compatible resolutions for streamlink
i=0
for resolution in $(echo $QUALITY | jq -r 'to_entries[]' | jq -r '.key'); do
    compat_res=$(echo $resolution | sed 's/30//g' | sed 's/chunked/1080p60/g')
    resolutions[$i]=$compat_res
    ((i++))
done

# Check if the desired resolition is in the array and then downlaod the video if it doesn't exist yet.
if containsElement $DESIRED_RES "${resolutions[@]}" ; then
    # Download the vod in the desired resolution
    if [ ! -f /opt/streamslurp/vods/vod-${VOD_DATE}.mp4 ]; then
        echo "File not found. Creating."
        streamlink $URL $DESIRED_RES  -o "/opt/streamslurp/vods/vod-${VOD_DATE}.mp4" --hls-segment-threads 2
    else
        echo "File exists."
    fi
else
    # Download with the best possible resolition
    if [ ! -f /opt/streamslurp/vods/vod-${VOD_DATE}.mp4 ]; then
        echo "File not found. Creating."
        streamlink $URL best -o "/opt/streamslurp/vods/vod-${VOD_DATE}.mp4" --hls-segment-threads 2
    else
        echo "File exists."
    fi
fi

