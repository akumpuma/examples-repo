#!/bin/bash
# Find duplicate files using shell script
# Remove duplicate files interactively

TMP_FILE=$(mktemp /tmp/temp_file.XXX)
DUP_FILE=$(mktemp /tmp/dup_file.XXX)

function add_file() {
    # Store the hash of the file if not already added
    echo "$1" "$2" >> $TMP_FILE
}

function red() {
    # Print colored output
    /bin/echo -e "\e[01;31m$1\e[0m" 1>&2
}

function del_file() {
    # Delete the duplicate file
    rm -f "$1" 2>/dev/null
    [[ $? == 0 ]] && red "File \"$1\" deleted"
}

function srch_file() {
    # Store the filename in this variable
    local NEW="$1"
    # Before we check hash value of file, make this variable null
    local SUM="0"

    # If file exists and the temporary file's size is zero
    if [ -f $NEW ] && [ ! -s $TMP_FILE ]; then
        # Print Store the hash value of file.
        # This value will be later stored in RET which is further used to check duplicate file
        echo $(sha512sum ${NEW} | awk -F ' ' '{print $1}')
        # Exit the loop here
        return
    fi

    # If the size of temporary file is non-zero
    # Read temporary file line by line in a loop.
    # Each line is stored in ELEMENT variable
    while read ELEMENT; do
        # Get the hash value of input file
        SUM=$(sha512sum ${NEW} | awk -F ' ' '{print $1}')
        # Get the hash value of file collected from temporary file
        ELEMENT_SUM=$(echo $ELEMENT | awk -F ' ' '{print $1}')
        ELEMENT_FILENAME=$(echo $ELEMENT | awk -F ' ' '{print $2}')

        # If the hash value is the same, we have found a duplicate file
        if [ "${SUM}" == "${ELEMENT_SUM}" ]; then
            echo $ELEMENT_FILENAME > $DUP_FILE
            return 1
        else
            continue
        fi
    done < $TMP_FILE

    # If duplicate file is not found, just print the hash value of the file
    echo "${SUM}"
}

# Example usage: Replace with the directory path you want to check for duplicate files
directories_to_check=("/path/to/your/folder")
check_for_duplicates "${directories_to_check}"
