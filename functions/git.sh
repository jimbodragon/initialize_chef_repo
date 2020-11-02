#!/bin/bash

function load_git_repos()
{
  source $git_repos_file
}
export -f load_git_repos

function install_git()
{
  if [ "$(for git in $(sudo apt-cache madison git | cut -d '|' -f 2); do sudo dpkg -l | grep git | grep $git; done | head -n 1 | awk '{print $1}')" != "ii" ]
  then
    #apt-get -y update && sudo apt-get -y upgrade
    apt-get -y install git
  fi
}
export -f install_git

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
export -f merging_from_fork

function initializing_git_submodule()
{
  # $1 = Repository name
  # $3 = git_url
  git submodule add $2 $1
  git submodule update --init $2.git $1
}
export -f initializing_git_submodule

function initializing_project_submodule()
{
  # $1 = Repository name
  # $2 = fork from public
  # $3 = git_url
  if [ "$3" == "" ]
  then
    initializing_git_submodule "$git_user@$git_baseurl:$git_org/$1.git" "$1"
  else
    initializing_git_submodule "$3" "$1"
  fi
  if [ "$2" != "" ]
  then
    merging_from_fork $1 $2
  fi
}
export -f initializing_project_submodule

function commit_and_push()
{
  git add *
  git commit -m "$1"
  git push
}
export -f commit_and_push

function initializing_cookbook()
{
  # $1 = cookbook name
  # $2 = fork from public
  # $3 = git_url
  if [ ! -d $1/.git ]
  then
    initializing_project_submodule $1 $2 $3
    if [ ! -f $1/metadata.rb ]
    then
      chef_generate cookbook $1
      cd $1
      commit_and_push "Initializing cookbook $1"
      cd ..
    fi
  fi
}
export -f initializing_cookbook

function chef_generate()
{
  echo "Generating $1 $2"
  chef generate $1 $2
}
export -f chef_generate

function executing_git_clone()
{
  # $1 = Repository type: [cookbooks. libraries, resources]
  # $2 = Repository name
  # $3 = fork from public
  # $4 = git_url
  # echo "initializing_cookbook in $(pwd) for type $1 for cookbook $2"
  if [ ! -d $1 ]
  then
    mkdir $1
  fi
  cd $1
  case $1 in
    "cookbooks" | "libraries" | "resources" )
      initializing_cookbook $2 $3 $4
    ;;&
    "libraries" )
      cd $2
      chef_generate helpers $2
    ;;&
    "resources" )
      cd $2
      chef_generate resource $2
    ;;&
    "libraries" | "resources" )
      commit_and_push "Initializing $1 $2"
      cd ..
    ;;
    "scripts" | "databag" | "environment" | "roles" | "nodes" )
      initializing_project_submodule $2 $3 $4
    ;;
  esac
  cd ..
}
export -f executing_git_clone

function git_clone_main_project()
{
  git_main_url="$git_user@$git_baseurl:$git_org/$git_main_project_name.git"
  if [ -d $git_main_project_name ] || [ "$(basename $(pwd))" == "$git_main_project_name" ]
  then
    if [ -d $git_main_project_name ]; then cd $git_main_project_name; fi
    if [ $(git remote -v 2>&1 | grep $git_main_url | wc -l) -eq 0 ] && [ $(git remote -v | grep origin | wc -l) -gt 0 ]
    then
      remote add second_origin $git_main_url
    fi
  else
    install_git
    git clone $git_main_url
    cd $git_main_project_nam
    echo "pwd = $(pwd)"
  fi
}
export -f git_clone_main_project

function download_git_raw()
{
  # ARG1 = Git repository name
  # ARG2 = File to download
  raw_url="https://raw.githubusercontent.com/$git_org/$1/main/"
  wget --quiet -O "$2" "$raw_url/$2"
}
export -f download_git_raw
