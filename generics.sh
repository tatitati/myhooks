
# alias
alias gra="./gradlew"
alias pls="sudo"
export CLICOLOR_FORCE=true # This variable is to force colors for the alias ls when pipe to awk
zhost=127.0.0.1:2181
khost=127.0.0.1:9092
issuer=user:16316963:23
alias lsmod="ls -lAachHLG | awk   '{k=0;for(i=0;i<=8;i++)k+=((substr(\$1,i+2,1)~/[rwx]/)*2^(8-i));if(k)printf(\"%0o \",k);print}'"
alias ls="ls -lAachHLG"

set_term_bgcolor() {
  local R=$1
  local G=$2
  local B=$3
  /usr/bin/osascript <<EOF
tell application "iTerm2"
  tell current session of current window
    set background color to {$(($R*65535/255)), $(($G*65535/255)), $(($B*65535/255)), 0}
  end tell
end tell
EOF
}

set_term_bgcolor $(($RANDOM % 25)) $(($RANDOM % 25)) $(($RANDOM % 25))


# folders
alias lab='cd ${HOME}/lab'

myhooks(){
   (cd ~/lab/myprojects/myhooks && code .)
}

lsfull(){
  if [[ -z $1 ]]
  then
    ls -d $PWD/*
  else
    ls -d $1/*
  fi
}


# generic
to(){
 projectName=$1
 foldername=$(ls --color=never $HOME/lab | grep --color=never $1 | awk '{print $9}')
 echo "moving to: ${foldername}" 
 if [[ ! -z $foldername ]]
 then
   cd $HOME/lab/$foldername
 else
   echo "Did you mean one of these *$projectName* folders?:"
   ls $HOME/lab | grep $projectName
 fi
}

mysymbols(){
   echo "\n\n"
   echo "│"
   echo "\n\n"
   echo "├──"
   echo "\n\n"
   echo "└──"}

notebook-create() {

 echo '{
  "cells": [],
  "metadata": {},
  "nbformat": 4,
  "nbformat_minor": 2
 }' > $(pwd)/$1.ipynb

 jupyter notebook $(pwd)/$1.ipynb

}



upper(){
	echo $1 | tr '[:lower:]' '[:upper:]'
}

lower(){
	echo $1 | tr '[:upper:]' '[:lower:]'
}

backup(){
    for file in "$@"
    do
        cp $file $file.backup
    done
}

yaml(){
   pbpaste | yq -P
}

yml(){
   pbpaste | yq -P
}

shout() {
  msg=${1:-completed}
  osascript -e "display notification  with title \"$msg\"" && say "$msg"
}

# aws

exportsaws(){
   export AWS_DEFAULT_REGION=eu-west-1
   export AWS_PROFILE=dev-production
   export AWS_DEFAULT_OUTPUT=yaml
}

unsetaws(){
   unset AWS_DEFAULT_REGION
   unset AWS_PROFILE
   unset AWS_DEFAULT_OUTPUT
}

# tree

treepath() {
    current_folder=$(pwd)
    folder=${1:-$current_folder}
    tree -C -f $folder -L 1
}


treefull () {
    current_folder=$(pwd)
    folder=${1:-$current_folder}
    tree -C $folder
    echo "\n"
    tree -C -f $folder
}

# move and restore

fpush() {
  folder_stack=~/stacksfolder
  current_folder=$(pwd)

  for file in "$@"
  do
     mv $file $folder_stack
  done

  echo "\nFolder stack:"
  ls $folder_stack
  echo "\nCurrent folder:"
  git s
}

fpop(){
  folder_stack=~/stacksfolder
  current_folder=$(pwd)
  tree -Cf $folder_stack
  echo "What file you want to pop to the current folder?:"
  read file
  mv $file $current_folder
  ls
}

# find

ffile() {
	find . -type f -name $1
}

ffolder(){
	find . -type dir -name $1
}

# create

newfile(){
 touch $1
 sublime $1
}

newdir(){
   mkdir -p $1
   cd $1
}

mtouch() {
	basename $1
	filename="$(basename -- $1)"
	dir=$(dirname $1)
	mdir $dir
	touch $filename
	blime $filename
}

unzip_targz() {
   tar xvzf $1
}

chpwd () {
   if [ "$(basename $PWD)" = "lab" ]; then
      ls
   fi

   if [ -f .ruby-version ]; then
      rbenv which irb
      #rbenv versions
   fi
   if [ -f Vagrantfile ]; then
      #vagrant status
   fi

   if [ -d .git ]; then
      git remote show origin | grep -i fetch
      echo `git branch | wc -l` local  branches
      git s
   
      reponame=$(basename -s .git `git config --get remote.origin.url`)
      foldername=$(basename $PWD)      
      project=`basename "$PWD"` | tr '[:lower:]' '[:upper:]'
      export PROJECT=${project}
      if [ $reponame != $foldername ]; then
        echo "changing folder name to match repo name...."
        cd ..
        echo "mv ${foldername} ${reponame}"
        mv $foldername $reponame
        cd $reponame
      fi
   fi

   if [ -f docker-compose.yml ]; then
      docker-compose config --services
      docker ps
   fi 

   if [ -f docker-compose.yaml ]; then
      docker-compose config --services
      docker ps
   fi

   if [ -f dbt_project.yml ]; then
      cat ${HOME}/.dbt/profiles.yml
   fi

   if [ -f dbt_project.yaml ]; then
      cat ${HOME}/.dbt/profiles.yml
   fi
}

versions(){
   echo "\n--> sdk current java"
   sdk current java
   echo "\n--> sdk current sbt"
   sdk current sbt   
   echo "\n--> anaconda -V"
   anaconda -V
   echo "\n--> python --version"
   python --version

   if [ -f build.sbt ]; then
      echo "\n--> sbt ';sbtVersion;scalaVersion'"
      sbt ';sbtVersion;scalaVersion'
   fi
}



# Useful for personal learning projects
ignore_scala () {
echo "
target
project/*
.idea
!project/Dependencies.scala
!project/build.properties
" > .gitignore

}

exclude(){
 echo $1 >> .git/info/exclude
 cat .git/info/exclude
}

high(){
   # example: 
   # aws cloudformation describe-stack-resources --stack-name FR-BI-DYNAMIC-FARE-ADJUSTMENTS-SCORES-CICD-DEV | high Type
   word=$1
   ack --ignore-case --passthru "${word}"
}

envcreate(){   
   envname=virtualenv-$(basename $PWD)
   python3 -m venv $envname 
   envactivate   
   echo $envname >> .git/info/exclude
}

envactivate(){  
   conda deactivate
   deactivate   
   envname=virtualenv-$(basename $PWD)  
   source $envname/bin/activate   
   which python
   pip -V
}

# this alias requires this tool: https://github.com/victorgarric/pip_search
alias pip='function _pip(){
    if [ $1 = "search" ]; then
        pip_search "$2";
    else pip "$@";
    fi;
};_pip'


# testme(){
#    if $(test -d "$1" -a -f "$2")
#    then
#       echo "yep!"
#    fi
# }

# testme2(){
#    if [ -d "$1" ] && [ -f "$2" ]; then
#       echo "yep!222"
#    fi
# }