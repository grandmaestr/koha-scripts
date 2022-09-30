#!/bin/bash

# This creates an audio file plus subtitles from a text file using Amazon Polly. You can change the VoiceID, 
# caption format, LanguageCode, and Engine
# Requires
# sudo apt install nodejs ffmpeg awscli npm
# Run aws configure or append the aws key and secret in the command
# Install using sudo npm install tts-cli -g
# See https://github.com/aws-samples/amazon-polly-closed-caption-subtitle-generator for more details
# set -e
# set -x
# Read columns from csv file
read -p "Enter the full path where you want to save your files, without the trailing slash (/path/to/directory): " outputdir

# Prompt the user for the csv file path
printf "The csv file must have column titles. The default used in this script are: \n preference - this is the category for each audio file. \n filename - this is the file name for the audio output. \n description - this is the text from which the audio will be created. \n"
read -p "Enter the full path to the csv file: " csvfile

# Prompt for overwrite
read -p "Do you want to overwrite the existing files? (y/n):  " response

# Create output directory if it does not exist
mkdir -p $outputdir

# Read columns from csv file
while IFS="," read -r Preference Filename Description
do
        while true;do
                case $response in
                        # If response is no, check for existing file. Skip if true
                        [nN][oO]|[nN] )
                                # Check if mp3 file already exists. Run if it does not.
                                if test -f "$outputdir/$Preference/$Filename.mp3"; then
                                        echo "$Filename already exists"
                                else
                                        # Make the preference directory if it doesn't exist
                                        mkdir -p $outputdir/$Preference
                                        echo "$Description" > /tmp/$Filename.txt
                                        tts /tmp/$Filename.txt $outputdir/$Preference/$Filename.mp3 --voice Amy --language en-GB --engine neural
                                fi
                                break;;
                        # If response is yes, create new file and overwrite existing
                        [yY][eE][sS]|[yY] )
                                # Make the preference directory if it doesn't exist
                                mkdir -p $outputdir/$Preference
                                echo "$Description" > /tmp/$Filename.txt
                 		polly-vtt $outputdir/$Preference/$Filename Amy mp3 "$(cat /tmp/$Filename.txt)" --caption-format srt --LanguageCode en-GB --Engine neural
                                break;;
                        * ) echo Invalid response.Try again;;
                esac
        done
done < $csvfile

