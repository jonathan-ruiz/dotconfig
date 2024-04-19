#!/bin/bash
VIEW() {

    biggest=-1
    tokeep=""

    echo "Analysing New Group"

    # Find the biggest in the group
    for f in "$@";do
        size=$(du -b "$f" | cut -f1)
        echo "$f: size in bytes: $size"
        if [ $size -gt $biggest ]; then
            biggest="$size"
            tokeep="$f"
        fi
    done

    # rename any file that is not the one to keep
    for f in "$@";do 
        if [ "$f" != "$tokeep" ]; then
            mv "$f" "$f.TODELETE"
            echo "deleting $f"
        else
            echo "keeping: $f"
        fi
    done 
}

