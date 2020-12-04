#!/bin/bash

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$(dirname $current_dir)/functions/initialize.sh"

install_path="/usr/local/chef_repo"

install_chef_workstation

#new_chef_infra "$new_project_name" "$new_git_branch" "$new_environment" "$new_git_main_project_name" "$new_git_org" $"new_git_baseurl" "$new_git_user" "$new_http_git" "$new_install_path"
new_chef_infra "JimboDragon" "master" "production" 'jimbodragon_chef_repo' 'jimbodragon' 'github.com' 'git' "https://raw.githubusercontent.com" $install_path "initialize_chef_repo"

execute_chef_solo $install_path "JimboDragon"
