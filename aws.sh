#! /bin/bash
GREEN='\033[0;32m'
NC='\033[0m'

aws_who(){
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


   stackname=${project}-${env}   
   echo "\n\nSTACK: ${stackname}"   
   aws cloudformation describe-stacks --stack-name ${stackname} | grep StackId
   aws cloudformation describe-stack-resources --stack-name ${stackname} | grep "PhysicalResourceId\|ResourceType"


   stackname=${project}-${env}-CATALOG
   echo "\n\nSTACK: ${stackname}"
   aws cloudformation describe-stacks --stack-name ${stackname} | grep StackId
   aws cloudformation describe-stack-resources --stack-name ${stackname} | grep "ResourceType\|PhysicalResourceId"


   stackname=${project}-CICD-${env}
   echo "\n\nSTACK: ${stackname}"
   aws cloudformation describe-stacks --stack-name $stackname | grep StackId
   aws cloudformation describe-stack-resources --stack-name $stackname | grep "ResourceType\|PhysicalResourceId"


   stackname=${project}-CODECOMMIT
   echo "\n\nSTACK: ${stackname}"
   aws cloudformation describe-stacks --stack-name $stackname | grep StackId
   aws cloudformation describe-stack-resources --stack-name $stackname | grep "ResourceType\|PhysicalResourceId"
}

codepipeline(){
   env=${2:-DEV}   
   url="https://eu-west-1.console.aws.amazon.com/codesuite/codepipeline/pipelines/${resource}/view?region=eu-west-1"
   open $url
}

codepipeline(){   
   resource=$1
   url="https://eu-west-1.console.aws.amazon.com/codesuite/codepipeline/pipelines/${resource}/view?region=eu-west-1"
   open $url
}

s3(){
   resource=$1
   url="https://s3.console.aws.amazon.com/s3/buckets/${resource}?region=eu-west-1&tab=objects"
   open $url
}

cloudformation(){      
   resource=$1      
   url="https://eu-west-1.console.aws.amazon.com/cloudformation/home?region=eu-west-1#/stacks/stackinfo?filteringStatus=active&filteringText=scores&viewNested=true&hideStacks=false&stackId=arn%3Aaws%3Acloudformation%3Aeu-west-1%3A800457644486%3Astack%2F${resource}"
   open $url
}