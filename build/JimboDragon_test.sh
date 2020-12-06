#!/bin/bash

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$(dirname $current_dir)/install/source_project.sh"

install_path="/usr/local/chef_repo"

#new_chef_infra "$project_name" "$git_branch" "$environment" "$git_main_project_name" "$git_org" "$git_baseurl" "$git_user" "$http_git" "$initialize_script_name" "$install_path" "$initial_role" "$initial_workstation_cookbook" "$initial_current_dir" "$default_chef_path" "$is_require_git_clone"
new_chef_infra "JimboDragon" "$git_branch" "$environment" "$git_main_project_name" "$git_org" "$git_baseurl" "$git_user" "$http_git" "$initialize_script_name" "$install_path" "$initial_role" "$initial_workstation_cookbook" "$initial_current_dir" "$default_chef_path" "$is_require_git_clone"

execute_chef_solo $install_path "JimboDragon"
