
# alias
alias ls="ls -lAachHLG"
alias gra="./gradlew"
alias pls="sudo"
export CLICOLOR_FORCE=true # This variable is to force colors for the alias ls when pipe to awk
export PATH=/Users/tati/bin:/usr/local/php5/bin:$PATH
export JAVA_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home
source "/Users/tati/.sdkman/bin/sdkman-init.sh"
zhost=127.0.0.1:2181
khost=127.0.0.1:9092
issuer=user:16316963:23
export AWS_DEFAULT_OUTPUT=yamlexport CLICOLOR_FORCE=true # This variable is to force colors for the alias ls when pipe to awk
export PATH=/Users/tati/bin:/usr/local/php5/bin:$PATH
export JAVA_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home
export AWS_DEFAULT_REGION=eu-central-1

# folders
alias lab='cd ${HOME}/lab'
alias de='cd ${HOME}/lab/de'

lfull(){
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
 if [[ -d $HOME/lab/de/$projectName ]]
 then
   cd $HOME/lab/de/$projectName
 else
   echo "Did you mean one of these *$projectName* folders?:"
   ls $HOME/lab/de | grep $projectName
 fi

}

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

newfile(){
 touch $1
 sublime $1
}

fsearch(){
   ls | grep $1 | awk '{print $9}' | grep $1
}

shout() {
  msg=${1:-Done}
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

lt() {
    current_folder=$(pwd)
    folder=${1:-$current_folder}
    tree -C -f $folder -L 1
}


tre () {
    current_folder=$(pwd)
    folder=${1:-$current_folder}
    tree -C $folder
    echo "\n"
    tree -C -f $folder
}


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


findfile() {
	find . -type f -name $1
}

findfolder(){
	find . -type dir -name $1
}

mtouch() {
	basename $1
	filename="$(basename -- $1)"
	dir=$(dirname $1)
	mdir $dir
	touch $filename
	blime $filename
}

mdir(){
   mkdir -p $1
   cd $1
}


unzip_targz() {
   tar xvzf $1
}

chpwd () {
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
   fi

   if [ -f docker-compose.yml ]; then
      docker ps
   fi 

   if [ -f docker-compose.yaml ]; then
      docker ps
   fi

   if [ -f dbt_project.yml ]; then
      cat ${HOME}/.dbt/profiles.yml
   fi

   if [ -f dbt_project.yaml ]; then
      cat ${HOME}/.dbt/profiles.yml
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
