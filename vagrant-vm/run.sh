#!/bin/bash

# Globals Start
option=$1
configFilePath=$2
myDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
commonPP="$myDir/common.pp"
modulesDir="$myDir/../puppet/modules"
manifestsDir="$myDir"
vmPropertiesFile="$myDir/.testvm.properties"

# Functions Start
setup_vagrantfile(){
  sed '/^  config.vm.box = ".*"$/ a\
    config.vm.provision :puppet, :module_path => "'$modulesDir'", :options => "--verbose --debug", :manifests_path => "'$manifestsDir'", :manifest_file => "config.pp"
  ' Vagrantfile > Vagrantfile.bk
  mv Vagrantfile{.bk,}
}

load_config(){
  local configFile=$1

  cp $commonPP config.pp && echo "[vinyas] Created config.pp from common.pp"
  cat $configFile >> config.pp && echo "[vinyas] Application config added to config.pp"
}

reload_config(){
  if [ -f $vmPropertiesFile ]; then
    local configFile=`cat $vmPropertiesFile | grep configFile | cut -d":" -f2`
    [[ -f $configFile ]] && load_config $configFile && echo "[vinyas] Reloaded configFile{:$configFile}"
  fi
}

save_config_file_path(){
  local configFile=$1
  echo "configFile:$configFile" > $vmPropertiesFile && echo "[vinyas] saved path to configFile{:$configFile}"
}

init(){
  clear

  local boxFile=$1
  local configFile=$2
  local boxFileName=${boxFile##*/}

  cd $myDir
  echo "[vinyas] Adding vagrant box named:" $boxFileName
  command vagrant box add $boxFileName $boxFile && echo "[vinyas] VM added"
  command vagrant init $boxFileName && echo "[vinyas] Vagrantfile created"
  setup_vagrantfile && echo "[vinyas] Vagrantfile setup done"

  save_config_file_path $configFile
  load_config $configFile
}

clear(){
  if [ -f Vagrantfile ]; then
    local boxFileName=`grep "  config.vm.box" Vagrantfile | sed 's/.*\"\(.*\)\"/\1/g'`
    local boxExists=`command vagrant box list | grep $boxFileName | wc -l`
    local boxDestroyed=`command vagrant status | grep default | grep "not created" | wc -l`

    [[ boxDestroyed -eq 0 ]] && command vagrant destroy -f && echo "[vinyas] VM destroyed"
    [[ ! boxExists -eq 0 ]] && command vagrant box remove $boxFileName && echo "[vinyas] VM removed"
    
    rm Vagrantfile && echo "[vinyas] Vagrantfile removed"
  fi

  [[ -f config.pp ]] && rm -f config.pp && echo "[vinyas] config.pp removed"
  [[ -f $vmPropertiesFile ]] && rm -f $vmPropertiesFile && echo "[vinyas] .testvm.properties deleted"
}

usage(){
  echo "**** HELP ****"
  echo "1) Make sure you are in vagrant-vm folder under vinyas"
  echo ""
  echo "2) Run: <sh run.sh init /path/to/image.box /path/to/configuration.pp>"
  echo "      This creates Vagrantfile and initiates Vagrant"
  echo "         .box is VirtualBox image file"
  echo "         .pp defines your puppet properties file which defines values puppet configuration specific to your environment"
  echo "         \`source\` causes vagrant command to be overridden to reload config file"
  echo ""
  echo "3) Execute vagrant up/halt/reload/package to test your changes"
  echo ""
  echo "4) Run: <sh run.sh clear> to delete extra created files and destroy vagrant"
}

vagrant(){
  if [ ! -z `echo "up reload" | grep -o $1` ]; then
    reload_config
  fi
  command vagrant $@
}
# Functions End

case $option in
  "init")
    init $2 $3
  ;;
  "clear")
    clear
  ;;
  "help")
    usage
  ;;
  *)
    usage
  ;;
esac