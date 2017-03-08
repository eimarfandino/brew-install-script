#!/bin/bash

. /etc/init.d/functions

# Use step(), try(), and next() to perform a series of commands and print
# [  OK  ] or [FAILED] at the end. The step as a whole fails if any individual
# command fails.
#
# Example:
#     step "Remounting / and /boot as read-write:"
#     try mount -o remount,rw /
#     try mount -o remount,rw /boot
#     next
step() {
    echo -n "$@"

    STEP_OK=0
    [[ -w /tmp ]] && echo $STEP_OK > /tmp/step.$$
}

try() {
    # Check for `-b' argument to run command in the background.
    local BG=

    [[ $1 == -b ]] && { BG=1; shift; }
    [[ $1 == -- ]] && {       shift; }

    # Run the command.
    if [[ -z $BG ]]; then
        "$@"
    else
        "$@" &
    fi

    # Check if command failed and update $STEP_OK if so.
    local EXIT_CODE=$?

    if [[ $EXIT_CODE -ne 0 ]]; then
        STEP_OK=$EXIT_CODE
        [[ -w /tmp ]] && echo $STEP_OK > /tmp/step.$$

        if [[ -n $LOG_STEPS ]]; then
            local FILE=$(readlink -m "${BASH_SOURCE[1]}")
            local LINE=${BASH_LINENO[0]}

            echo "$FILE: line $LINE: Command \`$*' failed with exit code $EXIT_CODE." >> "$LOG_STEPS"
        fi
    fi

    return $EXIT_CODE
}

next() {
    [[ -f /tmp/step.$$ ]] && { STEP_OK=$(< /tmp/step.$$); rm -f /tmp/step.$$; }
    [[ $STEP_OK -eq 0 ]]  && echo "[  OK  ]" || echo "[ FAILED ]"
    echo
    return $STEP_OK
}


# Homebrew Script for OSX
echo "Installing brew..."
#/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"


echo "***********Install dev stuff***********"

step "install node"
try brew install node
next

step "install git"
try brew install git
next

step "install github-desktop"
try brew cask install github-desktop
next

step "install github-desktop"
try brew cask install atom
next

step "install docker"
try brew cask install docker
next

step "install docker-compose"
try brew cask install docker-compose
next

#Communication Apps
echo "***********Communication stuff***********"
step "install slack"
try brew cask install slack
next

step "install skype"
try brew cask install skype
next

step "install lync"
try brew cask install microsfot-lync
next

echo "***********Web stuff***********"
step "install google-chrome"
try brew cask install google-chrome
next

step "install firefox"
try brew cask firefox
next
#
# brew cask install skype
# brew cask install microsoft-lync
#
# #Web Tools
# brew cask install google-chrome
# brew cask install firefox
#
