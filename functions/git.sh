#!/bin/bash

function load_cookbooks()
{
  $cookbooks_file
}

function install_git()
{
  apt-get update && sudo apt-get upgrade
  if [ "$(for git in $(sudo apt-cache madison git | cut -d '|' -f 2); do sudo dpkg -l | grep git | grep $git; done | head -n 1 | awk '{print $1}')" != "ii" ]
  then
    apt-get install git
  fi
}

function merging_from_fork()
{
  cd $1
  if [ $(git remote -v | awk '{print $1}' | grep $git_fork_upstream_name | head -n 1) != "" ]
  then
    git remote add $git_fork_upstream_name $2
    git fetch $git_fork_upstream_name
    git checkout master
    git merge $git_fork_upstream_name/master
    git push
  fi
  cd ..
}

function initializing_cookbook()
{
  if [ ! -d $1/.git ]
  then
    git submodule add $git_user@$git_baseurl:$git_org/$1.git $1
    git submodule update --init $git_user@$git_baseurl:$git_org/$1.git $1
    if [ ! -f $1/metadata.rb ]
    then
      echo "Generating cookbook $1"
      chef generate cookbook $1
      cd $1
      git add *
      git commit -m 'Initializing cookbook'
      git push
      cd ..
    fi
    if [ "$2" != "" ]
    then
      merging_from_fork $1 $2
    fi
  fi
}

function executing_git_clone()
{
  # $1 = cookbook type: [cookbooks. libraries, resources]
  # $2 = cookbook name
  echo "initializing_cookbook in $(pwd) for type $1 for cookbook $2"
  if [ ! -d $1 ]
  then
    mkdir $1
  fi
  cd $1
  initializing_cookbook $2 $3
  cd ..
}

function git_clone_main_project()
{
  install_git
  git clone $git_user@$git_baseurl:$git_org/$git_main_project_name.git
  cd jimbodragon_chef_repo
  echo "pwd = $(pwd)"
}
