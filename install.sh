#!/bin/bash

#. /etc/init.d/functions

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
    printf "\n$@"

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
    [[ $STEP_OK -eq 0 ]]  && printf "\n[  OK  ]" || printf "\n[ FAILED ]"
    echo
    return $STEP_OK
}

printf "\nDo you wish to install this homebrew?(y/n)? "
read answer
if echo "$answer" | grep -iq "^y" ;then
  #Homebrew Script for OSX
  echo "Installing brew..."
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

printf "\nDo you wish to install this dev packages?(y/n)? "
read answer
if echo "$answer" | grep -iq "^y" ;then

  echo "*********** Install dev stuff ***********"

  step "install java"
  try brew cask install java java6 java7 java8
  next

  step "Install JCE"
  try brew cask install jce-unlimited-strength-policy
  next

  step "install node"
  try brew install node
  next

  step "install git"
  try brew install git
  printf "\nLet's configure git global variables"
  printf "\nWhat is your email? "
  read reademail
  git config --global user.email $reademail
  printf "\nWhat is your firstname and lastname? "
  read readfullname
  git config --global user.name "$readfullname"
  next

  step "install github-desktop"
  try brew cask install github-desktop
  next

  step "install github-desktop"
  try brew cask install atom
  next

  step "install bash-git-prompt"
  try brew install bash-git-prompt
  echo 'if [ -f "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh" ]; then'  >>~/.bash_profile
  echo '  __GIT_PROMPT_DIR=$(brew --prefix)/opt/bash-git-prompt/share'  >>~/.bash_profile
  echo '  source "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh"'  >>~/.bash_profile
  echo 'fi'  >>~/.bash_profile
  next

  step "install maven"
  try brew install maven
  next

  step "install maven-completion"
  try brew install maven-completion
  next

  step "install gradle"
  try brew install gradle
  next

  step "install intellij"
  try brew cask install intellij-idea
  next

  step "install virtualbox"
  try brew cask install virtualbox
  next

  step "install docker"
  try brew cask install docker
  next

  step "install docker-compose"
  try brew install docker-compose
  next

  step "install soapui"
  try brew cask install soapui
  next
fi




printf "\nDo you wish to install this Communication packages?(y/n)? "
read answer
if echo "$answer" | grep -iq "^y" ;then

  #Communication Apps
  echo "*********** Communication stuff ***********"
  step "install slack"
  try brew cask install slack
  next

  step "install skype"
  try brew cask install skype
  next
fi

printf "\nDo you wish to install this web packages?(y/n)? "
read answer
if echo "$answer" | grep -iq "^y" ;then

  echo "*********** Web stuff ***********"
  step "install google-chrome"
  try brew cask install google-chrome
  next

  step "install firefox"
  try brew cask install firefox
  next

  step "install firefox"
  try brew cask install firefox
  next
fi

printf "\nDo you wish to generate ssh keys?(y/n)? "
read answer
if echo "$answer" | grep -iq "^y" ;then
  printf "\nWhat is your email address? "
  read email
  ssh-keygen -t rsa -b 4096 -C "$email"
  eval "$(ssh-agent -s)"
  ssh-add -K ~/.ssh/id_rsa
  pbcopy < ~/.ssh/id_rsa.pub
  printf "\nDo you wish to add keys to github and gitlab?(y/n)? "
  read addkeys
  if echo "$answer" | grep -iq "^y" ;then
    printf "\nWhat is your gitlab url? "
    read gitlaburl
    open -a /Applications/Safari.app https://github.com/settings/keys
    open -a /Applications/Safari.app $gitlaburl/profile/keys
    #open -a /Applications/Safari.app http://mny.gitlab.schubergphilis.com/profile/keys
  fi
fi

printf "\nDo you wish to add aliases to bash file?(y/n)? "
read answer
if echo "$answer" | grep -iq "^y" ;then
  echo 'if [ -f "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh" ]; then'  >>~/.bash_profile
  echo '  __GIT_PROMPT_DIR=$(brew --prefix)/opt/bash-git-prompt/share'  >>~/.bash_profile
  echo '  source "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh"'  >>~/.bash_profile
  echo 'fi'  >>~/.bash_profile
  echo ''
  echo '#[Alias]'  >>~/.bash_profile
  echo 'alias ll="ls -al"' >>~/.bash_profile
  echo 'alias gs="git status"'  >>~/.bash_profile
  echo 'alias gclean="git checkout ."'  >>~/.bash_profile
  echo 'alias gwipe="git clean -fdx"'  >>~/.bash_profile
  echo 'alias mica="mvn clean install"'  >>~/.bash_profile
  echo 'alias micant="mvn clean install -DskipTests"'  >>~/.bash_profile
  echo 'alias gipo="git pull origin master"'  >>~/.bash_profile
  echo 'alias gido="git pull origin `git rev-parse --abbrev-ref HEAD`"'  >>~/.bash_profile

  #shortcuts aliases
  printf "\nWhat is your code workspace for 'code' shortcut? "
  read -e -p ">" workspace
  echo "export code=$workspace"  >>~/.bash_profile
  echo "alias code='cd $workspace'"  >>~/.bash_profile
  source ~/.bash_profile
fi
