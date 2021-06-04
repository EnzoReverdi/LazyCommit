#!/bin/bash

DIR=$PWD
NOW=$(date +"%Y-%m-%d")

main () {
    cd $DIR

    ## Checking working directory
    if [[ ! -d .git ]]
    then
        echo "Your are not in the root of your repository, operation aborted"
        exit 1
    fi

    STATUSREPO=$(git status)

    ## If there's not already a CHANGELOG.md, set the version to 0.1.0
    ## init the trace
    if [[ ! -d .changelog ]]; then
        mkdir .changelog
        echo "0" > .changelog/version
        echo "0" >> .changelog/version
        echo "0" >> .changelog/version
        printf "Repo inited for versioning, Try to make some changes and report them by running \'lazycommit\'. To commit them just run \'lazycommit commit\'\n"
        exit 0
    fi        

    if [[ -n "$1" ]]; then
        if [[ "$1" != "commit" ]]; then
            echo "BAD ARGUMENT OPERATION ABORTED"
            exit 1
        else
            if [ ! -f .changelog/add ] && [ ! -f .changelog/change ] && [ ! -f .changelog/fix ] && [ ! -f .changelog/remove ]; then
                printf "You didn't write any entry (add/fix/change) for this version, are you sure you want to commit it ? [y/N]\n"
                while true; do
                    read -p "" yn
                    case $yn in
                        [yY]* ) break;;
                        [nN]* ) exit 0;;
                        * ) y/N;;
                    esac
                done
            fi
            MAJOR=$(sed '1!d' .changelog/version | grep -E -o "[0-9]+")
            MINOR=$(sed '2!d' .changelog/version | grep -E -o "[0-9]+")
            FIX=$(sed '3!d' .changelog/version | grep -E -o "[0-9]+")
            # MINOR=$(($MINOR+0))
            if [ $MAJOR -eq 0 ] && [ $MINOR -eq 0 ] && [ $FIX -eq 0 ]; then
                MINOR=$(($MINOR+1))
            else
                printf "What type of version is this commit ? [1-3]\n 1 - Major\n 2 - Minor\n 3 - Fix\n"
                while true; do
                    read -p "" yn
                    case $yn in
                        [1]* ) let "$MAJOR+1";break;;
                        [2]* ) let "$MINOR+1";break;;
                        [3]* ) let "$FIX+1";break;;
                        * ) [1-3];;
                    esac
                done
            fi
            echo "$MAJOR" > .changelog/version
            echo "$MINOR" >> .changelog/version
            echo "$FIX" >> .changelog/version
            ## add the modification to the changelog
            printf "\n## [${MAJOR}.${MINOR}.${FIX}] - ${NOW}" >> NEWCHANGELOG.md
            if [[ -f .changelog/add ]]; then
                printf "\n### Added\n" >> NEWCHANGELOG.md
                cat .changelog/add >> NEWCHANGELOG.md
                rm -rf .changelog/add
            fi
            if [[ -f .changelog/change ]]; then
                printf "\n### Changed\n" >> NEWCHANGELOG.md
                cat .changelog/change >> NEWCHANGELOG.md
                rm -rf .changelog/change
            fi
            if [[ -f .changelog/fix ]]; then
                printf "\n### Fixed\n" >> NEWCHANGELOG.md
                cat .changelog/fix >> NEWCHANGELOG.md
                rm -rf .changelog/fix
            fi
            if [[ -f CHANGELOG.md ]]; then
                cat CHANGELOG.md >> NEWCHANGELOG.md
                rm -rf CHANGELOG.md
            fi
            mv NEWCHANGELOG.md CHANGELOG.md
            ## Executed if the client didn t add file to commit.
            if [[ ! $STATUSREPO == *"Changes to be committed"* ]]; then
                git add --all
            else
                git add CHANGELOG.md
            fi
            git commit -m "$MAJOR.$MINOR.$FIX"
            git push
        fi
    else
        while true; do
        printf "What's the nature of the change? [1-3]
 1 - ➕ (added)
 2 - ♻️ (changed)
 3 - 🐛 (fixed)
 Press any key to exit\n"
        read -p "" yn
        case $yn in
            [1]* ) printf "# Tell me more about this ➕\n";read -p "" msg; echo "- $msg" >> .changelog/add;;
            [2]* ) printf "# Tell me more about this ♻️\n";read -p "" msg; echo "- $msg" >> .changelog/change;;
            [3]* ) printf "# Tell me more about this 🐛\n";read -p "" msg; echo "- $msg" >> .changelog/fix;;
            * ) break;;
        esac
    done
    fi
}

main $@