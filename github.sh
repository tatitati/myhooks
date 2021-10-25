#!/bin/bash

alias mygithub='open https://github.com/tatitati'
alias gmaster="git co master"


# github
alias prlist='gh pr list'
alias prstatus='gh pr status'

github(){
   compareWith=${1:-master}
   reponame=`basename $(git remote get-url origin) .git`
   branchname=`git branch --show-current`

   if [[ "$branchname" == "master" ]]; then
        open http://github.com/tatitati/${reponame}
   else
        open http://github.com/tatitati/${reponame}/compare/$compareWith..${branchname}#files_bucket
   fi
}

gcob(){
  git checkout -b $1
  git s
}

gcom(){
  git commit -m $1
  git s
}

gadd(){
  git add "$@"
  git s
}

gpull(){
  git pull
  git s
}

gpushu(){
  currentBranch=$(git rev-parse --abbrev-ref HEAD)
  git push -u origin $currentBranch
  git s
}
gremove(){
  branch=$1
  git branch -D $branch
  echo "remove in origin(y/n)?:"
  read answer
  if [[ $answer == "Y" || $answer == "y" ]]; then
    git push -d origin $branch
  fi
  git branch
}

prcreate(){
     echo "title?:"
     read title
     echo "body?:"
     read body
     body=${body:-$title}
     gpushu
     gh pr create --title $title --body $body
}

prmerge(){
     gh pr merge -sd
     git pull
     jenkins
}

pam(){
   if [[ -z $1 ]]; then
      git add .
   else
      files=($@)
      for file in $files
      do
        git add $file
      done
   fi

   echo "message?:"
   read message
   git commit -m $message
   git push
}

gclone() {
 reponame=$(basename $1 .git)
 git clone $1
 cd $reponame
}

ghist(){
  size=${1:-30}
  git log --color --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit -$size --reverse
}

gsquash(){
 branchname=`git branch --show-current`
 if [[ "$branchname" == "master" ]];then
     shout "Squash master?, No fucking way"
 else
     echo "From what branch?"
     read fromBranch
     echo "message?:"
     read message
     git reset $(git merge-base $fromBranch $branchname)
     git add .
     git commit -m "$message"
 fi
}

mypr(){
   reponame=`basename $(git remote get-url origin) .git`
   open https://github.com/tatitati/${reponame}/pulls/tatitati
}
