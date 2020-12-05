#!/bin/bash

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$(dirname $current_dir)/install/source_project.sh"

install_path="/usr/local/chef_repo"

install_chef_workstation

#new_chef_infra "$project_name" "$git_branch" "$environment" "$git_main_project_name" "$git_org" "$git_baseurl" "$git_user" "$http_git" "$install_path" "$initial_role" "$initial_workstation_cookbook"
new_chef_infra "JimboDragon" "$git_branch" "$environment" "$git_main_project_name" "$git_org" "$git_baseurl" "$git_user" "$http_git" "$install_path" "$initial_role" "$initial_workstation_cookbook"

execute_chef_solo $install_path "JimboDragon"
