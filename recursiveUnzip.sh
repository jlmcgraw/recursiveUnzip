#!/bin/bash
set -eu                # Always put this in Bourne shell scripts
IFS=$(printf '\n\t')  # Always put this in Bourne shell scripts

#Modified from original version at http://www.dbforums.com/showthread.php?1619154-how-to-unzip-files-recursively
#Other bits from http://tuxtweaks.com/2014/05/bash-getopts/

#
# Function  : runzip zip_file rm_flag
# Parameters: zip_file : File to unzip
#             rm_flag  = If set, remove zip file after unzip
#

# #Validate number of command line parameters
# if [ "$#" -ne 2 ] ; then
#   echo "Usage: $0 ZIP_FILE SHOULD_DELETE" >&2
#   echo "Speciy" >&2
#   exit 1
# fi



function runzip()
    {
        #
        # Get parameters
        local zip_file=$1
        local rm_flag=$2

        #echo "zip_file: $zip_file"
        
        # Exit if target .zip file doesn't exist
        if [[ ! -e ${zip_file} ]]
            then
                echo "$0 - Zip file not found : ${zip_file}" >&2
                return 1
            fi

        #Where to unzip the target .zip file to
        local zip_dir
        local new_zip_file
        local unzip_error_code

        #Destination subdirectory named after file under its directory
        #removing the .zip suffix
        zip_dir=$(dirname "${zip_file}")/$(basename "${zip_file}" .zip)


        #
        # Create unzip destination directory
        #
        #echo "zip_dir: $zip_dir"

        #Exit if we couldn't create the directory
        if [ ! -d "${zip_dir}" ]
        then
            if ! mkdir "${zip_dir}"
                then
                    echo "$0 - Failed to create directory : ${zip_dir}"
                    return 1
                fi
        fi

        #
        # Unzip into unzip directory
        #

        if ! unzip -qq "${zip_file}" -d "${zip_dir}"
            then
                echo "$0 - Unzip error for file : ${zip_file}"
                return 1
            fi

        #
        # Recursive unzip of new zip files
        #

        unzip_error_code=0


        #Read the list of zip files in zip_dir and extract them using process 
        #substitution instead of a temp file for the find
        #Note that there must be a space between the two < symbols to avoid confusion with the "here-doc" syntax of <<word. 
        while read -r new_zip_file
            do
                if ! runzip "${new_zip_file}" TRUE
                    then
                        unzip_error_code=$?
                        break
                    fi
            done < <(find "${zip_dir}" -type f -name '*.zip' -print)

        #
        # Remove zip file if required
        #
    #     echo "delete file : ${zip_file}"
        if [ "${rm_flag}" == "TRUE" -a ${unzip_error_code} -eq 0 ]
#         if [ -n "${rm_flag}" -a ${unzip_error_code} -eq 0 ]
            then
                if ! rm "${zip_file}"
                    then
                        echo "$0 - Failed to delete file : ${zip_file}"
                    fi
            fi

        return 0
    }


#Set Script Name variable
SCRIPT=`basename ${BASH_SOURCE[0]}`

#Initialize variables to default values.
SHOULD_DELETE=FALSE

#Set fonts for Help.
NORM=`tput sgr0`
BOLD=`tput bold`
REV=`tput smso`

#Help function
function HELP {
  echo -e \\n"${BOLD}${SCRIPT}${NORM}"\\n
  echo -e \\n"Recursively unzip files and any archives inside them"\\n
  echo -e "${REV}Basic usage:${NORM} ${BOLD}$SCRIPT <switches> file1.zip file2.zip ... fileN.zip${NORM}"\\n
  echo "Command line switches are optional. The following switches are recognized."
  echo -e \\t"${REV}-d${NORM}  --Delete the input file(s) after processing"
  echo -e \\t"${REV}-h${NORM}  --Displays this help message. No further functions are performed"\\n
  echo -e "Example: ${BOLD}$SCRIPT -d test.zip${NORM}"\\n
  exit 1
}

#Check the number of arguments. If none are passed, print help and exit.
NUMARGS=$#
# echo -e \\n"Number of arguments: $NUMARGS"
if [ $NUMARGS -eq 0 ]; then
  HELP
fi

### Start getopts code ###

#Parse command line flags
#If an option should be followed by an argument, it should be followed by a ":".
#Notice there is no ":" after "h". The leading ":" suppresses error messages from
#getopts. This is required to get my unrecognized option code to work.

while getopts :dh FLAG; do
  case $FLAG in
    d)  #set option "d"
      SHOULD_DELETE="TRUE"
#       echo "-d used:"
#       echo "SHOULD_DELETE = $SHOULD_DELETE"
      ;;
    h)  #show help
      HELP
      ;;
    \?) #unrecognized option - show help
      echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
      HELP
      #If you just want to display a simple error message instead of the full
      #help, remove the 2 lines above and uncomment the 2 lines below.
      #echo -e "Use ${BOLD}$SCRIPT -h${NORM} to see the help documentation."\\n
      #exit 2
      ;;
  esac
done

shift $((OPTIND-1))  #This tells getopts to move on to the next argument.

### End getopts code ###


### Main loop to process files ###

#This is where your main file processing will take place. This example is just
#printing the files and extensions to the terminal. You should place any other
#file processing tasks within the while-do loop.

while [ $# -ne 0 ]; do
  FILE=$1
  runzip "$1" $SHOULD_DELETE
#   TEMPFILE=`basename $FILE`
  #TEMPFILE="${FILE##*/}"  #This is another way to get the base file name.
#   FILE_BASE=`echo "${TEMPFILE%.*}"`  #file without extension
#   FILE_EXT="${TEMPFILE##*.}"  #file extension


#   echo -e \\n"Input file is: $FILE"
#   echo "File withouth extension is: $FILE_BASE"
#   echo -e "File extension is: $FILE_EXT"\\n
  shift  #Move on to next input file.
done

### End main loop ###

exit 0

#Call our function with the supplied command line parameter
# runzip "$1" remove_zip