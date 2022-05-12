# pip
# ---
loginpip(){
   aws codeartifact login --tool pip --repository cicd-tools --domain fr-bi-dev
}

# this alias requires this tool: https://github.com/victorgarric/pip_search
alias pip='function _pip(){
    if [ $1 = "search" ]; then
        pip_search "$2";
    else pip "$@";
    fi;
};_pip'

# generics
# ---

envdeactivate(){
   conda deactivate
   deactivate 
   source deactivate
}

envrefresh(){
   pip -V
   python -V
   loginpip
   pip install -r requirements.txt   
   pip list --local
}

# virtualenv
# ---

virtualenvcreate(){   
   pathpython=${1:-python}
   envdeactivate  
   envname=virtualenv-$(basename $PWD)
   virtualenv -p $pathpython $envname
   envactivate   
   echo $envname > .git/info/exclude   
   pip -V
   python -V
   loginpip
   pip install -r requirements.txt   
   pip list --local
}



virtualenvactivate(){  
   envdeactivate  
   envname=virtualenv-$(basename $PWD)  
   source $envname/bin/activate   
   python -V
   pip -V
   pip list --local
}


# conda
# ---
condacreate(){
   envdeactivate
   pythonversion=$1
   envname=conda-$(basename $PWD)
   virtualenv -p $pathpython $envname
   conda create --name $envname python=$pythonversion
   condaactivate      
   pip -V
   python -V
   loginpip
   pip install -r requirements.txt   
   conda list
}

condaactivate(){
    envname=conda-$(basename $PWD)
    source activate $envname
    python -V
    pip -V
    conda list
}

condadelete(){
    deactivate
    envname=conda-$(basename $PWD)
    conda env remove --name $envname
}