alias prview='gh pr view -w'

jenkins(){
   reponame=`basename $(git remote get-url origin) .git`
   branchname=`git branch --show-current`
   if [[ "$1" == "live" ]]; then
        open https://jenkins-master-eu-west-1.simplybusiness.live/job/simplybusiness/job/${reponame}/job/${branchname}/
   else
        open https://jenkins-master-eu-west-1.simplybusiness.me/job/simplybusiness/job/${reponame}/job/${branchname}/
   fi
}
