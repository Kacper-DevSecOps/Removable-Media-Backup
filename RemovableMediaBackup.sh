#!/bin/bash

shopt -s extglob nullglob
# shopt - This builtin allows you to change additional shell optional behavior.
# -s Enable each optname 
# extglob If set, the extended pattern matching features described are enabled. (see  https://www.gnu.org/software/bash/manual/html_node/Pattern-Matching.html#Pattern-Matching )
# nullglob -  If set, Bash allows filename patterns which match no files to expand to a null string, rather than themselves.



MEDIADIR=/media/$(whoami)

# You may omit the following subdirectories
# the syntax is that of extended globs, e.g.,
# OMITDIR="cmmdm|not_this_+([[:digit:]])|keep_away*"
# If you don't want to omit any subdirectories, leave empty: OMITDIR=
OMITDIR=omit

# Create array
if [[ -z $OMITDIR ]]; then
   CDARRAY=( "$MEDIADIR"/*/ )
else
   CDARRAY=( "$MEDIADIR"/!($OMITDIR)/ )
fi
# remove leading MEDIADIR:
CDARRAY=( "${CDARRAY[@]#"$MEDIADIR/"}" )
# remove trailing backslash and insert Exit choice
CDARRAY=( Exit "${CDARRAY[@]%/}" )

# At this point you have a nice array CDARRAY, indexed from 0 (for Exit)
# that contains Exit and all the subdirectories of $MEDIADIR
# You should check that you have at least one directory in there:
if ((${#CDARRAY[@]}<=1)); then
    printf 'No subdirectories found. Exiting.\n'
    exit 0
fi

# Display the menu:
printf 'Please choose from the following. Enter 0 to exit.\n'
for i in "${!CDARRAY[@]}"; do
    printf '   %d %s\n' "$i" "${CDARRAY[i]}"
done
printf '\n'

# Now wait for user input
while true; do
    read -e -r -p 'Your choice: ' choice
    # Check that user's choice is a valid number
    if [[ $choice = +([[:digit:]]) ]]; then
        # Force the number to be interpreted in radix 10
        ((choice=10#$choice))
        # Check that choice is a valid choice
        ((choice<${#CDARRAY[@]})) && break
    fi
    printf 'Invalid choice, please start again.\n'
done

# At this point, you're sure the variable choice contains
# a valid choice.
if ((choice==0)); then
    printf 'Good bye.\n'
    exit 0
fi

# Now you can work with subdirectory:

MEDIADEVICEPATH="/media/$(whoami)/${CDARRAY[choice]}"
MEDIABACKUPPATH="/home/$(whoami)/${CDARRAY[choice]}_Backup"

# Checking if the destination Backup directory exists 

if [ -d $MEDIABACKUPPATH ]
then
echo "Backup directory already exists, proceeding to the next step"
else
mkdir $MEDIABACKUPPATH
echo "Backup directory Created"
fi

cd $MEDIADEVICEPATH

#Coping media files based on their formats 

for MEDIAFORMAT in "*.jpg" "*.jpeg" "*.gif" "*.png" "*.mp3" "*.3gp" "*.mp4"

do
 echo "starting backup for $MEDIAFORMAT" 
 find $MEDIADEVICEPATH -name "$MEDIAFORMAT" -exec cp \{\} $MEDIABACKUPPATH \;
 echo "Backup of $MEDIAFORMAT ended" 
done
echo "Media Copied"

exit
