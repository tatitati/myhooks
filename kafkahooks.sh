#!/bin/bash

# service
# =======

zhost=127.0.0.1:2181
khost=127.0.0.1:9092

kafka-descibe(){
   kafkacat -L -b $khost
}

kafka-start(){
   brew services start zookeeper
   brew services start  kafka
   brew services list
   tlist
   glist
}

kafka-restart(){
   brew services restart kafka
   brew services list
   tlist
   glist
}


# Consume/Produce
# ===============
consumer(){
   group=${2:-mygroup}
   echo "\n- Using consumer group: ${group}"

   tdescribe $1
   gdescribe $group
   kafkacat -b $khost -G $group -f '\033[00;33m\] Partition: %p, offset: %o, key: %k, payload: \033[00m %s\n' $1
}

producer(){
   tlist
   tdescribe $1
   kafka-console-producer --broker-list $khost --topic $1
}


# Topics
# ======

tlist(){
  echo "\n- Topic List:"
  kafka-topics  --zookeeper $zhost --list
}

tcreate(){
  kafka-topics  --zookeeper $zhost --topic $1 --create --partitions 1 --replication-factor 1
  tlist
  tdescribe $1
}

tdelete(){
    for topic in "$@"
    do
        echo "\n- Deleting topic: $topic"
        kafka-topics  --zookeeper $zhost --topic $topic --delete
    done
    tlist
}

tpurge(){
  echo "\n- before deleting...."
  tdelete $1
  echo "\n- after deleting...."
  tcreate $1
}

tdescribe(){
   echo "\n- Decribing topic: $1"
   kafka-topics --describe --zookeeper $zhost --topic $1
}

# consumer-groups
# ===============

glist(){
   echo "\n- Consumer Groups:"
   kafka-consumer-groups --bootstrap-server $khost --list
}

gdescribe(){
  echo "\n- Describing group: $1"
  kafka-consumer-groups --bootstrap-server $khost --describe --group $1
}

gdelete(){
    for group in "$@"
    do
       echo "\n- Deleting consumer group: $group"
       kafka-consumer-groups --bootstrap-server $khost --delete --group $group
    done
    glist
}
