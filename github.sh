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

show_repo(){
  echo "tags"
  git ls-remote --tags
  echo "\norigin:"  
  git remote get-url origin
  echo "\nbranches:"  
  git branch -a
}

bitbucket () {
	reponame=`basename $(git remote get-url origin) .git`
  branchname=`git branch --show-current`
  echo $branchname
  open "https://stash.ryanair.com:8443/projects/BI/repos/${reponame}/compare/commits?sourceBranch=refs/heads/${branchname}&targetBranch=refs/heads/dev"
}

gempty(){
  echo "commit msg?"
  read msg
  git commit -m $msg --allow-empty
  git push
  git hist
}

gcob(){
  git checkout -b $1
  git s
}

gcom(){
  if [ -d ./docs ] && [ -d ./docs/diagrams ]; then
    # render mermaid templates
    find ./docs/diagrams/*.mmd -maxdepth 1 -exec mmdc -i {} \;
    git add docs/diagrams/*.mmd.svg
  fi
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

gadd_ext(){
   git s | grep $1 | awk '{print $2}' | xargs git add
   git s
}

gbranches(){
  git for-each-ref --format='%(color:cyan)%(authordate:format:%m/%d/%Y %I:%M %p)    %(align:25,left)%(color:yellow)%(authorname)%(end) %(color:reset)%(refname:strip=3)' --sort=authordate refs/remotes
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
  git log --color --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) = %cd %C(bold blue)<%an>%Creset' --abbrev-commit -$size --reverse
  
}

ignore(){
  echo -e "${1}" >> .gitignore
  cat .gitignore
  git s
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
