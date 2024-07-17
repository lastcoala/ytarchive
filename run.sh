set -e

# ./ytarchive --merge -o $1 $2 360p & echo $! > ytarchive_pid.txt

# echo "Sleeping for $3"

# sleep $3; kill -SIGINT $(cat ytarchive_pid.txt)

# echo "waiting for $1.mp4"
# while [ ! -f "$1.mp4" ]; do
#   sleep 10
# done

# gsutil cp "$1.mp4" "gs://kgdata-aiml-medea/livestream/publisher=$1/dt=$(date +%Y-%m-%d)/raw/video.mp4"


# Epoch time for 01:00 AM today
for hour in {00..01}; do
  now=$(date +%s)
  #echo "$hour"
  time_at_1am=$(date -d "$hour:00" +%s)

  # If current time is before 01:00 AM, adjust for 01:00 AM previous day
  if [ $now -lt $time_at_1am ]; then
    time_at_1am=$(($time_at_1am - 86400)) # Subtract 24 hours in seconds
  fi

  # Calculate difference in seconds
  seconds_ago=$(($now - $time_at_1am))
  filename="$hour-$1"
  #echo "$seconds_ago seconds ago was $hour:00"
  echo $filename

  ./ytarchive --merge --total-duration=3600 --live-maximum-seekable=$seconds_ago  -o $filename $2 360p

  ffmpeg -i $filename.mp4 -vn -acodec copy $filename.m4a

  gsutil cp "$filename.mp4" "gs://kgdata-aiml-medea/livestream/publisher=$1/dt=$(date +%Y-%m-%d)/raw/$filename-video.mp4"

  gsutil cp "$filename.m4a" "gs://kgdata-aiml-medea/livestream/publisher=$1/dt=$(date +%Y-%m-%d)/raw/$filename-audio.m4a"
done