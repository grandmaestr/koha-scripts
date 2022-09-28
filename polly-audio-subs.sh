#!/bin/bash

# This creates an audio file plus subtitles from a text file using Amazon Polly. You can change the VoiceID, 
# caption format, LanguageCode, and Engine
# Requires
# sudo apt install nodejs ffmpeg awscli npm
# Run aws configure or append the aws key and secret in the command
# Install using sudo npm install tts-cli -g
# See https://github.com/aws-samples/amazon-polly-closed-caption-subtitle-generator for more details
set -x
# Read columns from csv file
read -p "Enter the full path where you want to save your audio and subtitle files, without the trailing slash (/path/to/directory): " outputdir

# Create output directory if it does not exist
mkdir -p $outputdir

while IFS="," read -r preference filename description
do
# Check if mp3 file already exists. Run if it does not.
if test -f "$outputdir/$filename"; then
        echo "$filename already exists"
else
        # Make the preference directory if it doesn't exist
        cd $outputdir
        mkdir -p $preference
	cd $preference
        echo "$description" > /tmp/$filename.txt
	polly-vtt $filename Amy mp3 "$description" --caption-format srt --LanguageCode en-GB --Engine neural
        cd ../../
fi
done < koha-howto-aws-polly.csv
