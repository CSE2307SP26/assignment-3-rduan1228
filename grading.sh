#!/bin/bash

# ./grading.sh expected_output.txt output.txt < student_keys.txt
EXPECTED_OUTPUT="$1"
OUTPUT_FILE="$2"

DEADLINE="2026-02-12 10:00:00 -0600"
WORK_DIR=$(mktemp -d)
trap "rm -rf $WORK_DIR" EXIT

while IFS= read -r WUSTL_KEY; do
    git clone --quiet "https://github.com/CSE2307SP26/${WUSTL_KEY}.git" "$WORK_DIR/$WUSTL_KEY" 
    cd "$WORK_DIR/$WUSTL_KEY"
    git checkout --quiet cipher
    git checkout --quiet $(git log --before="$DEADLINE" --format="%H" -1) 
    javac Cipher.java 
    java Cipher > "$OUTPUT_FILE" 
    if [ -f "$OUTPUT_FILE" ]; then
        if [[ $(diff $OUTPUT_FILE $EXPECTED_OUTPUT -q -W) == "" ]]; then
            echo "$WUSTL_KEY 1"
        else
            echo "$WUSTL_KEY 0"
        fi
    else
        echo "$WUSTL_KEY 0"
    fi
    cd "$WORK_DIR"
done