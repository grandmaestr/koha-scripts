#!/bin/bash
# This script creates an audio file from a CSV file using Amazon Polly
# Requires
# sudo apt install nodejs ffmpeg awscli npm
# Run aws configure or append the aws key and secret in the command
# Install using sudo npm install tts-cli -g
# See https://github.com/eheikes/tts/tree/master/packages/tts-cli for more info#

set -x
set -e
# Read columns from csv file
read -p "Enter the full path where you want to save your files, without the trailing slash (/path/to/directory): " outputdir

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
	tts /tmp/$filename.txt $filename --voice Amy --language en-GB --engine neural
	cd ../../
fi
done < koha-howto-aws-polly.csv

