#!/bin/bash

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source $current_dir/../functions/generals.sh

install_git

git_clone_main_project

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
