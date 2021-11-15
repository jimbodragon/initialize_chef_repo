#!/bin/bash

function install_git()
{
  check_and_install git
  #get_github_netrc
}
export -f install_git

function install_jq()
{
  check_and_install jq
}
export -f install_jq

function merging_from_fork()
{
  project_folder=$1
  remote_project_url=$2

  remote_project_name=$(git remote -v | grep "$git_fork_upstream_name" | awk '{print $1}' | head -n 1)
  actual_remote_project_url=$(git remote -v | grep "$git_fork_upstream_name" | awk '{print $2}' | head -n 1)
  cd $project_folder
  if [ "$remote_project_name" == "" ]
  then
    git remote add $git_fork_upstream_name $remote_project_url
    git fetch $git_fork_upstream_name master
    git checkout $git_branch
    git merge $git_fork_upstream_name/master
    git push
  elif [ "$remote_project_url" == "$actual_remote_project_url" ]
  then
    log "Remote project '$remote_project_name' -> '$actual_remote_project_url' already exist"
  else
    log "Already have a remote project call '$git_fork_upstream_name' -> '$actual_remote_project_url'"
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
export -f initialize_git

function create_branch_and_switch()
{
  branch_name=$1

  git branch $branch_name
  git checkout $branch_name
}
export -f create_branch_and_switch

function merge_2_branches()
{
  destination_branch=$1
  source_branch=$2

  git merge $destination_branch $source_branch
}
export -f merge_2_branches

function initializing_git_submodule()
{
  git_url=$1
  folder_relative_path=$2

  log "From $(pwd), initializing $folder_relative_path with $git_url"
  git submodule add $git_url $folder_relative_path
  git submodule update --init $git_url $folder_relative_path
}
export -f initializing_git_submodule

function git_push_for_fork()
{
  fork_name=$1
  git push origin master --tags
  git push $fork_name
}
export -f git_push_for_fork

function commit_and_push()
{
  message=$1
  git add *
  git commit -m "$message"
  git push
}
export -f commit_and_push

function realign_commit_with_branch()
{
  message=$1
  default_upstream_name="$2"
  fork_name="$3"
  default_branch_name="$4"

  git add *
  git commit -m "$message"
  git branch temp
  git push -f $default_upstream_name $default_branch_name
  git branch master
  git branch -D temp
}
export -f realign_commit_with_branch

function add_commit_and_push_for_fork_mirror()
{
  message=$1
  fork_name="$2" # "fork"
  default_upstream_name="$3" # "origin"
  default_branch_name="$4" # "master"

  realign_commit_with_branch "$message" "$default_upstream_name" "$fork_name" "$default_branch_name"

  git pull $fork_name $default_branch_name
  git push $default_upstream_name $default_branch_name
}
export -f add_commit_and_push_for_fork_mirror

function update_from_fork()
{
  fork_name="$1" # "fork"
  default_upstream_name="$2" # "origin"
  default_branch_name="$3" # "master"

  git fetch $fork_name $default_branch_name
  git pull $fork_name $default_branch_name
  git push $default_upstream_name $default_branch_name
}
export -f update_from_fork

function git_push_submodule()
{
  for github_repo in "${git_repos[@]}"
  do
    cd $chef_repo
    eval $github_repo
    log "Pushing $type $name $fork_from_public $git_url"
    cd $type/$name
    commit_and_push "Push all $git_main_project_name project"
    echo
    echo
  done
}
export -f git_push_submodule

function git_clone_main_project()
{
  log "Cloning main project"
  install_git
  git_main_url="$git_user@$git_baseurl:$git_org/$git_main_project_name.git"
  if [ -d $git_main_project_name ] || [ "$(basename $(pwd))" == "$git_main_project_name" ]
  then
    if [ -d $git_main_project_name ]; then cd $git_main_project_name; fi
    if [ $(git remote -v 2>&1 | grep $git_main_url | wc -l) -eq 0 ] && [ $(git remote -v | grep origin | wc -l) -gt 0 ]
    then
      git remote add $project_name $git_main_url
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

function take_ownership()
{
  cd $chef_repo_path
  $type=$1
  initializing_git_submodule "$3" "$1/$2"
  cd "$1/$2"
  git remote rename origin $git_fork_upstream_name
  cd $chef_repo_path
}
export -f take_ownership
