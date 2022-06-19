#! /bin/bash
GREEN='\033[0;32m'
NC='\033[0m'

profile-set(){
   env=$1
   if [[ "$env" = "oat" || "$env" = "prod"  ]]; then
      export AWS_PROFILE=prod
   else
      export AWS_PROFILE=dev
   fi

   profile-show   
}

profile-show(){
   if [[ -z "${AWS_PROFILE}" ]]; then
      export AWS_PROFILE=dev
   fi

   tabset $AWS_PROFILE

   echo "\n${GREEN}--------- AWS CONFIGURE LIST${NC}"
   aws configure list

   # echo "\n${GREEN}--------- aws sts get-caller-identity${NC}"
   # aws sts get-caller-identity
}

codepipelinedeploy(){   
   env=$1
   profile-set $env

   echo "cicd_deploy $env"
   cicd_deploy $env
}

codecommitdeploy(){
   env=$1
   profile-set $env

   echo "cicd_deploy $env"
   codecommit_deploy $env 
}

credentials(){
   code /Users/albertf/.aws/credentials
}

s3_overwrite(){
   projectname=$(basename $PWD)
   tablename=$1
   local_path_to_upload=$2
   s3_folder=s3://${projectname}-dev/data/glue/${tablename}
   echo $s3_folder

   echo "overwrite s3 folder? [y/n]:"
   read message
   if [[ $message == "y" ]]; then
      echo "overwriting..."
      find ${local_path_to_upload} -name "*.crc" -exec rm {} \;
      aws s3 rm $s3_folder --recursive
      aws s3 cp ${local_path_to_upload} $s3_folder --recursive
   else
      echo "aborted"
   fi
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

describe(){
   reponame=`basename $(git remote get-url origin) .git`
   branchname=`git branch --show-current`  
   repo="https://stash.ryanair.com:8443/projects/BI/repos/${reponame}/compare/commits?sourceBranch=refs/heads/${branchname}&targetBranch=refs/heads/dev"
   echo "\n\nBITBUCKET: ${repo}"

   project=$(basename $PWD | tr '[:lower:]' '[:upper:]')
   env=${1:-dev}   

   profile-set $env

   env=$(echo $env | tr '[:lower:]' '[:upper:]')

   stackname=${project}-${env}   

   stackname=${project}-CODECOMMIT
   echo "\n\nCODECOMMIT STACK: ${stackname}"
   aws cloudformation describe-stacks --stack-name $stackname | grep StackId
   aws cloudformation describe-stack-resources --stack-name $stackname | grep "ResourceType\|PhysicalResourceId"

   stackname=${project}-CICD-${env}
   echo "\n\nCICD STACK: ${stackname}"
   aws cloudformation describe-stacks --stack-name $stackname | grep StackId
   aws cloudformation describe-stack-resources --stack-name $stackname | grep "ResourceType\|PhysicalResourceId"

   echo "\n\nAPP STACK: ${stackname}"   
   aws cloudformation describe-stacks --stack-name ${stackname} | grep StackId
   aws cloudformation describe-stack-resources --stack-name ${stackname} | grep "PhysicalResourceId\|ResourceType"


   stackname=${project}-${env}-CATALOG
   echo "\n\nCATALOG STACK: ${stackname}"
   aws cloudformation describe-stacks --stack-name ${stackname} | grep StackId
   aws cloudformation describe-stack-resources --stack-name ${stackname} | grep "ResourceType\|PhysicalResourceId"
}

describe-local(){
    awslocal sns list-topics
    awslocal sqs list-queues
}

secret(){
   secret_id=$1
   aws secretsmanager  get-secret-value --secret-id $secret_id
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

glue(){
   db=$1   
   open "https://eu-west-1.console.aws.amazon.com/glue/home?region=eu-west-1#database:catalog=800457644486;name=${db}"
}

toairflow(){
   env=${1:-DEV}
   open "https://eu-west-1.console.aws.amazon.com/mwaa/home?region=eu-west-1#environments/FR-BI-AIRFLOW-${env}-2/sso"
}

loginecr(){
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

catalogoutput(){   
   # requirements:
   # pip install yamllint
   # pip install cfn-lin
   # pip install pydot
   # brew install graphviz
   # brew install eddieantonio/eddieantonio/imgcat
   env=${1:-dev}

   echo "\n${GREEN}Finding catalog files${NC}"
   find aws/catalog -type f -name "*.yml"

   echo "\n${GREEN}Validating basic yml format of catalog filest${NC}"
   find aws/catalog -type f -name "*.yml" -exec yamllint -d relaxed {} \;


   echo "\n${GREEN}generating CATALOG template merged${NC}"
   cf_template -d aws/catalog -o catalog.yml
   cat catalog.yml | yq

   echo "\n${GREEN}generating merged PARAMS${NC}"
   python -m cf_config -t aws/common/tags.json -p aws/catalog/params/${env}_params.json -e ${env} -o params.json
   cat params.json | jq


   echo "\n${GREEN}validating CATALOG template${NC}"
   # aws cloudformation validate-template --template-body file://$(pwd)/infra.yml
   cfn-lint catalog.yml -g
   dot -Tpng catalog.yml.dot -o doc/catalog.png
   imgcat doc/catalog.png
   rm catalog.yml.dot
   # rm catalog.yml
   # rm params.json
}

infraoutput(){   
   # requirements:
   # pip install yamllint
   # pip install cfn-lin
   # pip install pydot
   # brew install graphviz
   # brew install eddieantonio/eddieantonio/imgcat
   env=${1:-dev}

   echo "\n${GREEN}Finding infra files${NC}"
   find aws/infra -type f -name "*.yml"

   echo "\n${GREEN}Validating basic yml format of infra filest${NC}"
   find aws/infra -type f -name "*.yml" -exec yamllint -d relaxed {} \;


   echo "\n${GREEN}generating INFRA template merged${NC}"
   cf_template -d aws/infra aws/common -o infra.yml
   cat infra.yml | yq

   echo "\n${GREEN}generating merged PARAMS${NC}"
   python -m cf_config -t aws/common/tags.json -p aws/infra/params/common_params.json aws/infra/params/${env}_params.json -e ${env} -o params.json
   cat params.json | jq


   echo "\n${GREEN}validating INFRA template${NC}"
   # aws cloudformation validate-template --template-body file://$(pwd)/infra.yml
   cfn-lint infra.yml -g
   dot -Tpng infra.yml.dot -o docs/infra.png
   imgcat docs/infra.png
   rm infra.yml.dot
   rm infra.yml
   rm params.json
}

cicdoutput(){   
   # requirements
   # pip install yamllint
   # pip install cfn-lin
   # pip install pydot
   # brew install graphviz
   # brew install eddieantonio/eddieantonio/imgcat
   env=${1:-dev}

   echo "\n${GREEN}Finding cicd files${NC}"
   find aws/cicd/pipeline aws/common f -name "*.yml"

   echo "\n${GREEN}Validating basic yml format of cicd filest${NC}"
   find aws/cicd/pipeline aws/common f -name "*.yml" -exec yamllint -d relaxed {} \;

   echo "\n${GREEN}generating CICD template merged${NC}"
   cf_template -d aws/cicd/pipeline aws/common -o cicd.yml
   cat cicd.yml | yq

   # echo "\n${GREEN}generating merged PARAMS${NC}"
   # python -m cf_config -t aws/common/tags.json -p aws/infra/params/common_params.json aws/infra/params/{env}_params.json -e {env} -o params.json
   # cat params.json | jq


   echo "\n${GREEN}validating CICD template${NC}"
   # aws cloudformation validate-template --template-body file://$(pwd)/cicd.yml
   cfn-lint cicd.yml -g
   dot -Tpng cicd.yml.dot -o docs/cicd.png
   imgcat docs/cicd.png
   rm cicd.yml.dot
   rm cicd.yml
   # rm params.json
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

ecr-pull(){
   loginecr
   repositoryname=$1
   docker pull 800457644486.dkr.ecr.eu-west-1.amazonaws.com/${repositoryname}
}

ecr-list(){
   aws ecr describe-repositories | grep repositoryName
}

ecr-list-images(){
   repo=$1
   aws ecr list-images --repository-name $repo
}

s3-list(){
   aws s3 ls
}

lambda-list(){
   aws lambda list-functions | grep FunctionName
}

sqs-list(){
   aws sqs list-queues
}

sns-list(){
   aws sns list-topics
}

s3-bucket-delete(){
   bucket=$1
   aws s3 rm s3://$bucket --recursive
   aws s3api delete-bucket --bucket $bucket
}

ecr-delete(){
   reponame=$1   
   aws ecr delete-repository --repository-name $reponame
}

aws-list(){
   name=$1
   echo "ecr..."
   ecr-list | grep $name
   echo "s3..."
   s3-list | grep $name
   echo "lambda..."
   lambda-list | grep $name
   echo "sqs..."
   sqs-list | grep $name
   echo "sns..."
   sns-list | grep $name
}