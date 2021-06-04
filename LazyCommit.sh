#!/bin/bash

DIR=$PWD
STATUSREPO=$(git status)

main () {
    cd $DIR

    if [[ ! -d .git ]]
    then
        echo "Your are not in the root of your repository, operation aborted"
        exit 1
    fi

    if [[ -n "$1" ]]; then
        if [[ "$1" != "-a" ]]; then
            echo "BAD ARGUMENT OPERATION ABORTED"
            exit 1
        else
            if [[ ! $STATUSREPO == *"Changes to be committed"* ]]; then
                echo "You didn't add file to commit, aborting operation"
                exit 1
            fi
        fi
    else
        if [[ $STATUSREPO == *"Changes not staged for commit:"* ]]; then
            git add --all
        else
            echo "Nothing to commit, abborting operation"
            exit 1
        fi
    fi

}

main $@