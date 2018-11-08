#!/bin/bash

set -e

access_token=$1;
file_name=LFS_Elephant.STL;

echo Uploading $file_name to CloudSlicer;

upload_response="$(curl -sX POST \
  https://cloudslicer.makerbot.com/files \
  -H "Authorization: Bearer $access_token" \
  -F file=@$file_name)";

# Get file URI from server response
# Usually you would just parse the JSON & get the "url" key value
upload_uri=$(echo $upload_response | grep -oEi 'https.+"}');

# Trim the last character
upload_uri=$(echo $upload_uri | rev | cut -c 3- | rev);

echo Uploaded to CloudSlicer

echo Starting slice
slice_response=$(curl -sX POST \
  https://cloudslicer.makerbot.com/slices \
  -H "Authorization: Bearer $access_token" \
  -H 'Content-Type: application/json' \
  -d "{
	\"url\": \"$upload_uri\",
	\"config\": \"replicator2\"
}");

# Get job status URL from server response
# Usually you would just parse the JSON & get the "url" key value

job_url=$(echo $slice_response | grep -oEi '\/slices\/.+",');

# Trim the last 2 characters
job_url=$(echo $job_url | rev | cut -c 3- | rev);
full_job_url=https://cloudslicer.makerbot.com$job_url;

echo Done! Check the status of your slice @ $full_job_url;
