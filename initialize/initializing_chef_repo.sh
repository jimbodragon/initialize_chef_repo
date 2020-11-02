#!/bin/bash

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source $current_dir/../functions/generals.sh

git_clone_main_project
cd ..
chef generate repo -r --chef-license accept $git_main_project_name

cd $git_main_project_name
mkdir scripts
cat $0 > scripts/$(basename $0)

git add scripts/*
git commit -m 'Initializing repo'

load_cookbooks

git add cookbooks
git add libraries
git add resources
git commit -m 'Initializing cookbooks'

git push
