#! /bin/bash
GREEN='\033[0;32m'
NC='\033[0m'

aws_show(){
   tree -f ~/.aws

   echo "\n${GREEN}--------- CONFIG${NC}"
   cat ~/.aws/config

   echo "\n${GREEN}--------- CREDENTIALS${NC}"
   cat ~/.aws/credentials   

   echo "\n${GREEN}--------- ENV${NC}"
   export | grep -i aws

   echo "\n${GREEN}--------- AWS CONFIGURE LIST${NC}"
   aws configure list

   echo "\n${GREEN}--------- aws sts get-caller-identity | jq${NC}"
   aws sts get-caller-identity | jq 
}

aws_resources(){
   project=`basename "$PWD"` | tr '[:lower:]' '[:upper:]'
   env=${2:-DEV}   
   
   echo "\n\nSTACK: ${project}-${env}"
   aws cloudformation  describe-stack-resources --stack-name ${project}-${env} | grep "PhysicalResourceId\|ResourceType"
   echo "\n\nSTACK: ${project}-${env}-CATALOG"
   aws cloudformation  describe-stack-resources --stack-name ${project}-${env}-CATALOG | grep "ResourceType\|PhysicalResourceId"
   echo "\n\nSTACK: ${project}-CICD-${env}"
   aws cloudformation  describe-stack-resources --stack-name ${project}-CICD-${env} | grep "ResourceType\|PhysicalResourceId"
   echo "\n\nSTACK: ${project}-CODECOMMIT"
   aws cloudformation  describe-stack-resources --stack-name ${project}-CODECOMMIT | grep "ResourceType\|PhysicalResourceId"
}