#!/bin/bash

# This creates an audio file plus subtitles from a text file using Amazon Polly. You can change the VoiceID, 
# caption format, LanguageCode, and Engine
# Requires
# sudo apt install nodejs ffmpeg awscli npm
# Run aws configure or append the aws key and secret in the command
# Install using sudo npm install tts-cli -g
# See https://github.com/aws-samples/amazon-polly-closed-caption-subtitle-generator for more details
set -e
set -x
# Read columns from csv file
read -p "Enter the full path where you want to save your files, without the trailing slash (/path/to/directory): " outputdir

# Prompt the user for the csv file path
printf "The csv file must have column titles. The default used in this script are: \n preference - this is the category for each audio file. \n filename - this is the file name for the audio output. \n description - this is the text from which the audio will be created. \n"

read -p "Enter the full path to the csv file: " csvfile

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
done < $csvfile
