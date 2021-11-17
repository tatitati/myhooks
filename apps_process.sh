#!/bin/bash
alias kil="kill -9"
alias services='brew services list'

# apps

typora(){
  open -na "typora.app" --args "$@"
}

sublime(){
	/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl ${1:-.}
}


# process lifecycle
running(){
  services
  docker ps
}

start(){
    for serv in "$@"
    do
        brew services start $serv
    done
    brew services list
}

restart(){
    for serv in "$@"
    do
        brew services restart $1
    done
    brew services list
}

stop() {
    for serv in "$@"
    do
        brew services stop $1
    done
    brew services list
}

killport(){
        echo "with lsof...."
        lsof -t -i tcp:$1 | xargs kill
        showport $1
}


showport(){
        echo "with lsof...."
        lsof -i :$1
        echo "with netstat....."
        netstat -anv | grep $1
}

showpid(){
        ps -Ao user,pid,command | grep -v grep | grep $1
}
