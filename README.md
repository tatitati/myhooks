# how to inject all this hooks

add this content to .bash_profile

```shell
newhooks(){
		source ~/lab/myprojects/myhooks/generics.sh
		source ~/lab/myprojects/myhooks/github.sh
		source ~/lab/myprojects/myhooks/apps_process.sh
		source ~/lab/myprojects/myhooks/docker.sh
		source ~/lab/myprojects/myhooks/sites.sh
                source ~/lab/myprojects/myhooks/kafkahooks.sh
}

newhooks
```