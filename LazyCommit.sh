#!/bin/bash
DIR=$PWD

main () {
    if [[ -n "$1" ]]; then
        if [[ "$1" != "-a"]]; then
            echo "BAD ARGUMENT OPERATION ABORTED"
        fi
    else
        git add --all
    fi
}

main $@