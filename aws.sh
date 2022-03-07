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