#!/bin/bash

# Script: generate_stls.sh
# Description: This script reads strings from a text file, passes each string as a parameter to an OpenSCAD file,
#              and generates STL files with the names specified in the input text file. The generated STL files
#              are placed under a "dist" folder.
# Parameters:
#   $1: Path to the input text file containing one string per line.

# Check if input file and OpenSCAD file are provided as parameters
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

# Assign input file and OpenSCAD file paths to variables
input_file="$1"
openscad_file="words_key_chain.scad"
dist_folder="dist_j"

# Check if input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: Input file '$input_file' not found!"
    exit 1
fi

# Check if OpenSCAD file exists
if [ ! -f "$openscad_file" ]; then
    echo "Error: OpenSCAD file '$openscad_file' not found!"
    exit 1
fi

# Create dist folder if it doesn't exist
mkdir -p "$dist_folder"

# Loop through each line in the input file
while IFS= read -r line; do
    # Trim leading and trailing whitespace from the line
    line=$(echo "$line" | xargs)

    echo -e "\e[1mGenerating STL for:\e[0m \e[1;32m$line\e[0m"
    
    # Generate STL using OpenSCAD and the current line as parameter
    output_stl="${dist_folder}/${line}.stl"
    openscad -o "$output_stl" -D "first_word=\"${line}\"" "$openscad_file"
    
    # Check if the STL file was generated successfully
    if [ -f "$output_stl" ]; then
        echo "Generated: $output_stl"
    else
        echo -e "\e[91mFailed to generate:\e[0m $output_stl"
    fi
done < "$input_file"
