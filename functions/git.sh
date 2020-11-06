#!/bin/bash

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $current_dir/../data/$(basename "${BASH_SOURCE[0]}")

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
  project_folder=$1
  remote_project_url=$2
  git_upstream_name=$git_fork_upstream_name #$3
  branch_to_fork_with=$4

  branch_to_fork_with='master'

  remote_project_name=$(git remote -v | grep "$git_upstream_name" | awk '{print $1}' | head -n 1)
  actual_remote_project_url=$(git remote -v | grep "$git_upstream_name" | awk '{print $2}' | head -n 1)
  cd $project_folder
  if [ $remote_project_name == "" ]
  then
    git remote add $git_upstream_name $remote_project_url
    git fetch $git_upstream_name master
    git checkout $branch_to_fork_with
    git merge $git_upstream_name/master
    git push
  elif [ "$remote_project_url" == "$actual_remote_project_url" ]
  then
    echo "Remote project '$remote_project_name' -> '$actual_remote_project_url' already exist"
  else
    echo "Already have a remote project call '$git_upstream_name' -> '$actual_remote_project_url'"
  fi
  cd ..
}
export -f merging_from_fork

function initialize_git()
{
  branch_name=$1

  git init
  touch README.md
  git add README.md
  git commit -m 'Initializing git repo for project $(basename $(pwd))'
  if [ "$branch_name" != "master" ]
  then
    create_branch_and_switch $branch_name
  fi
}

function create_branch_and_switch()
{
  branch_name=$1

  git branch $branch_name
  git checkout $branch_name
}
export -f initializing_git_submodule

function merge_2_branches()
{
  destination_branch=$1
  source_branch=$2

  git merge $destination_branch $source_branch
}
export -f initializing_git_submodule

function initializing_git_submodule()
{
  folder_relative_path=$1
  git_url=$2
  git submodule add $git_url $folder_relative_path
  git submodule update --init $git_url $folder_relative_path
}
export -f initializing_git_submodule

function initializing_project_submodule()
{
  repository_name=$1
  fork_from_public=$2
  git_url=$3
  if [ "$git_url" == "" ]
  then
    initializing_git_submodule "$git_user@$git_baseurl:$git_org/$repository_name.git" "$repository_name"
  else
    initializing_git_submodule "$git_url" "$repository_name"
  fi
  if [ "$fork_from_public" != "" ]
  then
    merging_from_fork $repository_name $fork_from_public
  fi
}
export -f initializing_project_submodule

function git_push_for_fork()
{
  fork_name=$1
  git push origin master --tags
  git push $fork_name
}

function commit_and_push()
{
  message=$1
  git add *
  git commit -m "$message"
  git push
}
export -f commit_and_push

function add_commit_and_push_for_fork_mirror()
{
  message=$1
  fork_name="$2"
  default_upstream="master"
  fork_branch="master"

  git add *
  git commit -m "$message"
  git branch temp
  git push -f origin $fork_branch
  git branch -D temp
  git pull $fork_name $fork_branch
  git push origin master
}
export -f add_commit_and_push_for_mirror

function git_push_submodule()
{
  load_git_repos

  for github_repo in "${git_repos[@]}"
  do
    cd $main_repo_dir
    eval $github_repo
    echo "Pushing $type $name $fork_from_public $git_url"
    cd $type/$name
    commit_and_push "Push all $git_main_project_name project"
    echo
    echo
  done
}
export -f git_push_submodule

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
    git submodule update --init --recursive .
  else
    install_git
    git clone $git_main_url
    cd $git_main_project_name
    git submodule update --init --recursive .
  fi
}
export -f git_clone_main_project

function download_git_raw()
{
  git_repository_name=$1
  file_to_download=$2
  raw_url="https://raw.githubusercontent.com/$git_org/$git_repository_name/master/"
  wget --quiet -O "$file_to_download" "$raw_url/$file_to_download"
}
export -f download_git_raw
