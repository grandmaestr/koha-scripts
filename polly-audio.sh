#!/bin/bash
# This script creates an audio file from a CSV file using Amazon Polly
# Requires
# sudo apt install nodejs ffmpeg awscli npm
# Run aws configure or append the aws key and secret in the command
# Install using sudo npm install tts-cli -g
# See https://github.com/eheikes/tts/tree/master/packages/tts-cli for more info#

# set -x
# set -e
# Prompt user for the save directory path
read -p "Enter the full path where you want to save your files, without the trailing slash (/path/to/directory): " outputdir

# Prompt the user for the csv file path
printf "The csv file must have column titles. The default used in this script are: \n preference - this is the category for each audio file. \n filename - this is the file name for the audio output. \n description - this is the text from which the audio will be created. \n"

read -p "Enter the full path to the csv file: " csvfile

# Create output directory if it does not exist
mkdir -p $outputdir

# Read columns from csv file
while IFS="," read -r Preference Filename Description
do

# Check if mp3 file already exists. Run if it does not.
#if test -f "$outputdir/$Preference/$Filename.mp3"; then
#	echo "$Filename already exists"
#else
	# Make the preference directory if it doesn't exist
	mkdir -p $outputdir/$Preference
	echo "$Description" > /tmp/$Filename.txt
	tts /tmp/$Filename.txt $outputdir/$Preference/$Filename.mp3 --voice Amy --language en-GB --engine neural
#fi
done < $csvfile

