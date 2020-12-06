#!/bin/bash

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$(dirname $current_dir)/install/source_project.sh"

run_project_require=1

#new_chef_infra "$project_name" "$git_branch" "$environment" "$git_main_project_name" "$git_org" "$git_baseurl" "$git_user" "$http_git" "$initialize_script_name" "$install_path" "$initial_role" "$initial_workstation_cookbook" "$initial_current_dir" "$default_chef_path" "$is_require_git_clone" "$install_file_name"
new_chef_infra "JimboDragon" "$git_branch" "test" "$git_main_project_name" "$git_org" "$git_baseurl" "$git_user" "$http_git" "$initialize_script_name" "$install_path" "$initial_role" "$initial_workstation_cookbook" "$initial_current_dir" "$default_chef_path" "$is_require_git_clone" "$install_file_name"

execute_chef_solo $install_path "JimboDragon"
