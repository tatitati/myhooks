#! /bin/bash
GREEN='\033[0;32m'
NC='\033[0m'

credentials(){
   code /Users/albertf/.aws/credentials
}

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

   echo "\n${GREEN}--------- aws sts get-caller-identity${NC}"
   aws sts get-caller-identity
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

describe-local(){
    awslocal sns list-topics
    awslocal sqs list-queues
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

sqs(){

}

sns(){

}

dynamo(){
   table=$1
   url="https://eu-west-1.console.aws.amazon.com/dynamodbv2/home?region=eu-west-1#table?initialTagKey=&name=${table}&tab=overview"
   open $url
}

cloudwatch(){

}

toairflow(){
   env=${1:-DEV}
   open "https://eu-west-1.console.aws.amazon.com/mwaa/home?region=eu-west-1#environments/FR-BI-AIRFLOW-${env}-2/sso"
}

ecrlogin(){
   aws ecr get-login-password --profile=default | docker login --username AWS --password-stdin 800457644486.dkr.ecr.eu-west-1.amazonaws.com
}

s3tree(){
   bucket=$1
   depth=${2:-2}   
   
   echo "\n/data"
   s3-tree $bucket /data $depth | yq eval -P
   echo "\n\n/code"
   s3-tree $bucket /code $depth | yq eval -P
}

cfoutput(){   
   # requirements:
   # pip install cfn-lin
   # pip install pydot
   # brew install graphviz
   # brew install eddieantonio/eddieantonio/imgcat
   env={1:-dev}

   echo "\n${GREEN}generating INFRA template merged${NC}"
   cf_template -d aws/infra -o infra.yml
   cat infra.yml | yq

   echo "\n${GREEN}generating merged PARAMS${NC}"
   python -m cf_config -t aws/common/tags.json -p aws/infra/params/common_params.json aws/infra/params/{env}_params.json -e {env} -o params.json
   cat params.json | jq


   echo "\n${GREEN}validating INFRA template${NC}"
   # aws cloudformation validate-template --template-body file://$(pwd)/infra.yml
   cfn-lint infra.yml -g
   dot -Tpng infra.yml.dot -o infra.png
   imgcat infra.png
}

cfvalidate(){
   aws cloudformation validate-template --template-body file://$1
}

ssm(){
   aws ssm get-parameter --name $1
}

codeartifact(){
   aws codeartifact login --tool pip --repository cicd-tools --domain fr-bi-dev
   aws codeartifact login --tool twine --repository cicd-tools --domain fr-bi-dev
}