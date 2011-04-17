#!/bin/sh
#
# 17/04/2011
#

URXVT=urxvt
YOUTUBE_DL=/home/will/youtube/youtube-dl
YOUTUBE_DL_OPTIONS="-o /home/will/youtube/%(stitle)s.%(id)s.%(ext)s"
# Time before launching media player (seconds)
SLEEP_TIME=5
MEDIA_PLAYER=mplayer

if [ $# -ne 1 ]
then
	echo "Usage: $0 <YouTube URL>"
	exit 1
fi

URL=$1

# Get filename for media player
FNAME=`$YOUTUBE_DL --get-filename $YOUTUBE_DL_OPTIONS "$URL"`
$URXVT -e $YOUTUBE_DL $YOUTUBE_DL_OPTIONS "$URL" &
sleep $SLEEP_TIME
$MEDIA_PLAYER $FNAME.part
