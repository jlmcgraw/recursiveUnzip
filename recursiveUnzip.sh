#!/bin/bash
set -eu                # Always put this in Bourne shell scripts
IFS="`printf '\n\t'`"  # Always put this in Bourne shell scripts

#
# Function  : runzip zip_file rm_flag
# Parameters: zip_file : File to unzip
#             rm_flag  = If set, remove zip file after unzip
#

#BUG TODO: All zip files inside the original file are extracted in the same 
#directory and not whatever subdirectory they were in in the base archive

runzip()
{
    #
    # Get parameters
    #

    local zip_file=$1
    local rm_flag=$2

    #If the target isn't all zip files then add a .zip extension to it
    #which will get trimmed by basename
    if [[ "${zip_file}" != *.zip ]]
        then
            zip_file=${zip_file}.zip
        fi

    echo "zip_file: $zip_file"

    #
    # Declare local variables
    #

    local zip_dir
    local zip_list
    local new_zip_file
    local new_unzip_error_code

    #
    # Verify that zip file exists
    if [[ ! -e ${zip_file} ]]
        then
            echo "$0 - Zip file not found : ${zip_file}" >&2
            return 1
        fi

    #
    # Create unzip directory
    #

    #Unzip to subdirectory nameed after file under current working directory
    #removing the .zip suffix
#     zip_dir=$PWD/$(basename ${zip_file} .zip)
    zip_dir=$(dirname ${zip_file})/$(basename ${zip_file} .zip)

    echo "zip_dir: $zip_dir"

    if [ ! -d ${zip_dir} ]
    then
        if ! mkdir ${zip_dir}
            then
                echo "$0 - Failed to create directory : ${zip_dir}"
                return 1
            fi
    fi

    #
    # Unzip in unzip directory
    #

    if ! unzip -qq ${zip_file} -d ${zip_dir}
        then
            echo "$0 - Unzip error for file : ${zip_dir}/${zip_file}"
            return 1
        fi

    #
    # Recursive unzip of new zip files
    #

    unzip_error_code=0
    #Save the current directory and change to where we just unzipped to
#     pushd ${zip_dir}

    #Read the list of zip files in zip_dir and extract them
    #Using process substitution instead of a temp file for the find
    #Note that there must be a space between the two < symbols to avoid confusion with the "here-doc" syntax of <<word. 
    while read -r new_zip_file
        do
            if ! runzip ${new_zip_file} remove_zip
                then
                    unzip_error_code=$?
                    break
                fi
        done < <(find ${zip_dir} -type f -name '*.zip' -print)

#     popd

    #
    # Remove zip file if required
    #
echo "delete file : ${zip_dir}/${zip_file}"
#     if [ -n "${rm_flag}" -a ${unzip_error_code} -eq 0 ]
#         then
#             if ! rm ${zip_file}
#                 then
#                     echo "$0 - Failed to delete file : ${zip_dir}/${zip_file}"
#                 fi
#         fi

    return 0
}

runzip $1 $2