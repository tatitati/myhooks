#!/bin/bash
alias dc="docker-compose"

drun(){
  image=$1
  docker run -it $image /bin/bash
}

drun-here(){
  image=$1
  place_to_mount=$2
  docker run --rm -it -v $(pwd):${place_to_mount} $image /bin/bash
}

dexec(){
  container=$1
  if [[ -z $2 ]]; then
     docker exec -it $container /bin/bash
  else
    docker exec -it --user $2 $container  /bin/bash
  fi
}

dps(){
  name=$1
  docker ps -a  |  grep $name | awk '{print $1}'
}

dstop(){
   name=$1
   docker stop $(dps $name)
}

dimages(){
  imagename=$1
  docker images |  grep $imagename | awk '{print $3}'
}

drm(){
  name=$1
  if [ "${name}"="*" ]; then
    docker rm -f $(docker ps -aq)
    docker rmi -f $(docker images -aq)
  else
    docker rm -f $(dps $name)
    docker rmi -f $(dimages $name)
  fi   
  docker system prune --all --force # clean cache as well
}

drm_container(){
   name=$1
   docker rm $(dps $name)
}

drm_image(){
   name=$1
   docker rmi $(dimages $name)
}

dclean(){
  docker stop $(docker ps -q)
  docker rm $(docker ps -qa)
  docker rmi $(docker images -qa) --force
  docker volume prune
}

dtidy(){
  docker rmi $(docker images -f dangling=true -q) -f
}
