#!/bin/bash

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source $current_dir/../functions/generals.sh

install_git

git_clone_main_project

load_cookbooks

for github_repo in "${cookbooks[@]}"
do
  #echo "github_repo = $github_repo"
  eval $github_repo
  executing_git_clone "$type" "$name" "$fork_from_public" "$git_url"
done
